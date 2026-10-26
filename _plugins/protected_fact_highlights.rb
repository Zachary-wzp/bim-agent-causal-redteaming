require 'cgi'
require 'kramdown'
require 'kramdown/parser/gfm'
require 'kramdown/converter/html'
require 'rexml/document'
require 'rexml/xpath'
require 'uri'

# Responses are data: support Markdown structure without interpreting HTML, Liquid,
# inline attributes, embedded assets or kramdown extensions as executable content.
class Kramdown::Parser::CaseOutput < Kramdown::Parser::GFM
  TABLE_SEPARATOR = /\A[ \t]*\|?[ \t]*:?-{3,}:?[ \t]*(?:\|[ \t]*:?-{3,}:?[ \t]*)*\|?[ \t]*\r?\n?\z/
  def initialize(source, options)
    super
    @block_parsers -= %i[block_html block_extensions block_math footnote_definition abbrev_definition]
    @span_parsers -= %i[span_extensions inline_math smart_quotes typographic_syms footnote_marker]
  end

  def parse_list
    Kramdown::Parser::Kramdown.instance_method(:parse_list).bind_call(self)
  end

  def parse_span_html
    add_text(@src.getch)
    true
  end

  def parse_table
    return false unless @src.rest.lines[1]&.match?(TABLE_SEPARATOR)
    super
  end
end

class Kramdown::Converter::CaseOutput < Kramdown::Converter::Html
  def convert_header(el, indent)
    el.attr.clear
    super
  end

  def convert_a(el, indent)
    href = el.attr['href'].to_s
    uri = URI.parse(href)
    return inner(el, indent) unless uri.scheme == 'https' && uri.host && !uri.userinfo
    "<a href=\"#{CGI.escapeHTML(href)}\" rel=\"noopener noreferrer\">#{inner(el, indent)}</a>"
  rescue URI::InvalidURIError
    inner(el, indent)
  end

  def convert_img(el, _indent)
    CGI.escapeHTML(el.attr['alt'].to_s)
  end

  def convert_html_element(el, indent)
    # The parser only creates this node for GFM strikethrough; raw HTML is disabled.
    raise ArgumentError, 'Unexpected HTML in case output' unless el.value == 'del'
    "<del>#{inner(el, indent)}</del>"
  end

  def convert_table(el, indent)
    "<div class=\"output-table-scroll\" tabindex=\"0\" role=\"region\" aria-label=\"Scrollable output table\">#{super}</div>"
  end

  def convert_td(el, indent)
    super.sub('<th', '<th scope="col"')
  end
end

module ProtectedFactHighlights
  OUTPUT_OPTIONS = {input: 'CaseOutput', auto_ids: false, header_offset: 2,
                    syntax_highlighter: nil, math_engine: nil, hard_wrap: false,
                    entity_output: :numeric, gfm_quirks: %i[no_auto_typographic paragraph_end]}.freeze

  def output_markdown(text)
    # GFM allows a table directly after a paragraph. kramdown's table parser needs
    # a blank line; insert it for rendering only, without touching fenced code.
    lines, rendered, fence = text.lines, [], nil
    separator = Kramdown::Parser::CaseOutput::TABLE_SEPARATOR
    lines.each_with_index do |line, index|
      if (match = line.match(/\A {0,3}(`{3,}|~{3,})/))
        if fence.nil?
          fence = match[1]
        elsif match[1][0] == fence[0] && match[1].length >= fence.length
          fence = nil
        end
      end
      if !fence && index > 0 && !lines[index - 1].strip.empty? &&
         !line.start_with?('    ', "\t") && line.include?('|') && lines[index + 1]&.match?(separator)
        rendered << "\n"
      end
      rendered << line
    end
    rendered.join
  end

  def output_document(text)
    doc = Kramdown::Document.new(output_markdown(text), **OUTPUT_OPTIONS)
    html = Kramdown::Converter::CaseOutput.convert(doc.root, doc.options).first
    REXML::Document.new("<div>#{html}</div>", respect_whitespace: :all)
  end

  def output_text_nodes(doc)
    REXML::XPath.match(doc.root, './/text()')
  end

  # Collapse presentation whitespace while retaining a map back to DOM text offsets.
  def normalized_output(text)
    normalized, positions = +'', []
    text.each_char.with_index do |char, index|
      if char.match?(/\s/)
        next if normalized.end_with?(' ')
        char = ' '
      end
      normalized << char
      positions << index
    end
    [normalized, positions]
  end

  def occurrences(text, fragment)
    positions, cursor = [], 0
    while (index = text.index(fragment, cursor))
      positions << index
      cursor = index + 1
    end
    positions
  end

  def render_case_output(text, highlights)
    text = text.to_s
    # Keep the existing source-range checks even when called outside a Jekyll build.
    highlight_protected_facts(text, highlights)
    doc = output_document(text)
    nodes = output_text_nodes(doc)
    plain = nodes.map(&:value).join
    normalized, positions = normalized_output(plain)
    ranges = Array(highlights).each_with_index.map do |span, index|
      source_matches = occurrences(text, span['text'])
      fragment = normalized_output(span['text']).first.strip
      raise ArgumentError, 'Highlight has no visible Markdown text' if fragment.empty?
      visible_matches = occurrences(normalized, fragment)
      if visible_matches.size != source_matches.size
        fragment_doc = output_document(span['text'])
        fragment = normalized_output(output_text_nodes(fragment_doc).map(&:value).join).first.strip
        raise ArgumentError, 'Highlight has no visible Markdown text' if fragment.empty?
        visible_matches = occurrences(normalized, fragment)
      end
      # Match the same occurrence, never all instances of a protected value. If
      # formatting makes attribution ambiguous, fail instead of coloring a guess.
      unless source_matches.size == visible_matches.size
        raise ArgumentError, 'Ambiguous Markdown highlight; review the exact annotated passage'
      end
      ordinal = source_matches.index(span['start'])
      first = visible_matches.fetch(ordinal)
      [positions.fetch(first), positions.fetch(first + fragment.length - 1) + 1, index]
    end
    ranges.sort_by!(&:first)
    ranges.each_cons(2) { |a, b| raise ArgumentError, 'Overlapping rendered highlights' if a[1] > b[0] }
    offset = 0
    nodes.each do |node|
      value = node.value
      finish = offset + value.length
      pieces = ranges.select { |first, last, _| first < finish && last > offset }
      unless pieces.empty?
        cursor = 0
        pieces.each do |first, last, index|
          start_at = [first - offset, 0].max
          end_at = [last - offset, value.length].min
          node.parent.insert_before(node, REXML::Text.new(value[cursor...start_at], true)) if start_at > cursor
          mark = REXML::Element.new('mark')
          mark.add_attributes('class' => 'protected-fact', 'data-highlight-index' => index.to_s,
                              'title' => 'Protected information disclosed to this requester')
          mark.add(REXML::Text.new(value[start_at...end_at], true))
          node.parent.insert_before(node, mark)
          cursor = end_at
        end
        node.parent.insert_before(node, REXML::Text.new(value[cursor..], true)) if cursor < value.length
        node.parent.delete(node)
      end
      offset = finish
    end
    unless output_text_nodes(doc).map(&:value).join == plain
      raise ArgumentError, 'Highlighting changed the rendered text'
    end
    doc.root.children.map(&:to_s).join
  end

  # Offsets refer to Unicode characters in the original text, with an exclusive end.
  # Both highlighted and ordinary text are escaped; annotations never contain HTML.
  def highlight_protected_facts(text, highlights)
    text = text.to_s
    cursor = 0
    html = +''
    Array(highlights).each do |span|
      first, last = span.values_at('start', 'end')
      unless first.is_a?(Integer) && last.is_a?(Integer) && first >= cursor &&
             last > first && last <= text.length && text[first...last] == span['text']
        raise ArgumentError, 'Invalid protected-fact highlight'
      end
      html << CGI.escapeHTML(text[cursor...first])
      html << '<mark class="protected-fact" title="Protected information disclosed to this requester">'
      html << CGI.escapeHTML(text[first...last]) << '</mark>'
      cursor = last
    end
    html << CGI.escapeHTML(text[cursor..])
  end
end

Liquid::Template.register_filter(ProtectedFactHighlights)
