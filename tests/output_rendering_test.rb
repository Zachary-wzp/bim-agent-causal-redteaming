require 'liquid'
require 'rexml/xpath'
require_relative '../_plugins/protected_fact_highlights'

renderer = Object.new.extend(ProtectedFactHighlights)
checks = 0
verify = lambda do |name, &block|
  raise name unless block.call
  checks += 1
  puts "PASS #{name}"
end
render = ->(text, spans = []) { REXML::Document.new('<div>' + renderer.render_case_output(text, spans) + '</div>', respect_whitespace: :all) }
nodes = ->(doc, query) { REXML::XPath.match(doc, query) }
text_of = ->(doc) { REXML::XPath.match(doc, './/text()').map(&:value).join }
span = ->(text, value, offset = 0) { first = text.index(value, offset); {'start' => first, 'end' => first + value.length, 'text' => value} }

md = "# Report {#agent-output}\n\n## Details\n\n- Item **one**\n- Item *two*\n\n1. First\n2. Second\n\n> Note\n\n`inline`\n\n~~~text\n| Code | Only |\n|---|---|\n<&>\n~~~\n"
doc = render.call(md)
verify.call('nested headings retain the page heading hierarchy') { nodes.call(doc, '//h1 | //h2').empty? && nodes.call(doc, '//h3').size == 1 && nodes.call(doc, '//h4').size == 1 }
verify.call('output cannot inject conflicting heading IDs') { nodes.call(doc, '//*[@id]').empty? }
verify.call('lists, emphasis and blockquotes render') { %w[ul ol strong em blockquote].all? { |tag| !nodes.call(doc, '//' + tag).empty? } }
verify.call('code preserves literal Markdown and metacharacters') { nodes.call(doc, '//pre').size == 1 && text_of.call(nodes.call(doc, '//pre').first).include?("|---|---|\n<&>") && nodes.call(doc, '//table').empty? }

table = "Intro without a blank line\n| Item | Value |\n|---|---|\n| A | **Secret** |\n| B | Secret |\n"
marked = span.call(table, 'Secret', table.index('| B'))
doc = render.call(table, [marked])
verify.call('GFM tables render immediately after a paragraph') { nodes.call(doc, '//table').size == 1 && nodes.call(doc, '//th').size == 2 }
verify.call('tables are keyboard-scrollable and have column headers') { nodes.call(doc, '//div[@role="region"][@tabindex="0"]').size == 1 && nodes.call(doc, '//th[@scope="col"]').size == 2 }
verify.call('only the annotated repeated value is highlighted') { nodes.call(doc, '//tbody/tr[1]//mark').empty? && nodes.call(doc, '//tbody/tr[2]//mark').size == 1 }

cross = '😀 Sensitive **classified** content.'
doc = render.call(cross, [span.call(cross, 'Sensitive **classified** content')])
verify.call('a highlight can cross formatting nodes without losing strong text') { nodes.call(doc, '//strong/mark').size == 1 && nodes.call(doc, '//mark').map { |m| text_of.call(m) }.join == 'Sensitive classified content' }
verify.call('split marks share one passage identity') { nodes.call(doc, '//mark').map { |m| m.attributes['data-highlight-index'] }.uniq == ['0'] }

code = 'The literal `*secret*` stays literal.'
doc = render.call(code, [span.call(code, '*secret*')])
verify.call('a code highlight preserves literal formatting characters') { text_of.call(nodes.call(doc, '//code/mark').first) == '*secret*' }
code = "~~~text\nA  secret  Z\n    indentation\n~~~"
doc = render.call(code, [span.call(code, 'secret')])
verify.call('highlighting preserves code spacing and indentation') { text_of.call(nodes.call(doc, '//pre/code').first) == "A  secret  Z\n    indentation\n" }
entity = 'Protected A &amp; B.'
doc = render.call(entity, [span.call(entity, 'A &amp; B')])
verify.call('entity decoding retains the correct protected text') { text_of.call(nodes.call(doc, '//mark').first) == 'A & B' }

unsafe = "<script>window.injected = true</script>\n\n<iframe src='https://unsafe.invalid/'></iframe>\n\n<img src=x onerror=alert(1)>\n\n[unsafe](javascript:alert%281%29)\n\n[data](data:text/html,hello)\n\n![image](https://unsafe.invalid/image.png)\n\nText\n{: onclick=\"alert(1)\"}\n\n{{ 7 | plus: 8 }}"
doc = render.call(unsafe)
verify.call('raw scripts and embedded elements remain inert text') { nodes.call(doc, '//script | //iframe | //img').empty? && text_of.call(doc).include?('<script>window.injected = true</script>') }
verify.call('unsafe links and inline attributes cannot execute') { nodes.call(doc, '//a | //*[@onclick] | //*[@onerror]').empty? }
verify.call('Liquid remains literal text') { text_of.call(doc).include?('{{ 7 | plus: 8 }}') }
verify.call('a literal pipe does not become a headerless table') { nodes.call(render.call('A | B'), '//table').empty? }
doc = render.call('[HTTPS](https://github.com/)')
verify.call('HTTPS links keep their label and safe destination') { nodes.call(doc, '//a[@href="https://github.com/"]').size == 1 }

ambiguous = '[Secret](https://host.invalid/Secret)'
verify.call('ambiguous source-to-rendered occurrences fail closed') do
  begin
    render.call(ambiguous, [span.call(ambiguous, 'Secret')])
    false
  rescue ArgumentError => e
    e.message.include?('Ambiguous Markdown highlight')
  end
end
verify.call('incorrect source ranges still fail before rendering') do
  begin
    render.call('Secret', [{'start' => 0, 'end' => 6, 'text' => 'Wrong!'}])
    false
  rescue ArgumentError
    true
  end
end

puts "#{checks} Markdown rendering checks passed."
