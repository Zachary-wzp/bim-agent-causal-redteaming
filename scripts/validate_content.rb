#!/usr/bin/env ruby
# Validate source content without executing Liquid, HTML, or case text.
require 'yaml'
require 'date'
require 'uri'
require 'pathname'
require 'ipaddr'
require 'digest'

class ContentValidator
  attr_reader :errors
  INTENDED = %w[over_collection direct_exposure indirect_exposure unknown].freeze
  OBSERVED = (INTENDED + %w[none]).freeze
  OUTCOMES = %w[leakage_observed no_leakage_observed inconclusive].freeze
  MAIN_ROUTES = %w[/ /platform/ /cases/ /statistics/ /progress/ /resources/].freeze

  def initialize(root, today: (Time.now.getutc + 8 * 3600).to_date)
    @root = File.expand_path(root)
    @today = today
    @errors = []
    @routes = MAIN_ROUTES.dup
  end

  def error(path, message)
    @errors << "#{path}: #{message}"
  end

  def yaml(text, path)
    # Duplicate mapping keys otherwise silently overwrite review flags.
    tree = Psych.parse_stream(text)
    visit = lambda do |node|
      if node.is_a?(Psych::Nodes::Mapping)
        keys = node.children.each_slice(2).map { |key, _| key.respond_to?(:value) ? key.value : nil }
        error(path, 'duplicate YAML mapping key') if keys.uniq.size != keys.size
      end
      (node.respond_to?(:children) ? node.children : nil)&.each { |child| visit.call(child) }
    end
    visit.call(tree)
    YAML.safe_load(text, permitted_classes: [Date], aliases: false)
  rescue Psych::Exception => e
    error(path, "invalid or unsafe YAML (#{e.class})")
    nil
  end

  def object(value, path)
    return value if value.is_a?(Hash)
    error(path, 'must be a mapping')
    {}
  end

  def array(value, path)
    return value if value.is_a?(Array)
    error(path, 'must be an array')
    []
  end

  def required(data, keys, path)
    keys.each do |key|
      error(path, "#{key} must be nonempty text") unless data[key].is_a?(String) && !data[key].strip.empty?
    end
  end

  def boolean(data, key, path)
    error(path, "#{key} must be a boolean") unless [true, false].include?(data[key])
  end

  def enum(data, key, choices, path)
    error(path, "invalid #{key}") unless choices.include?(data[key])
  end

  def date(value, path, required: false)
    return if !required && (value.nil? || value == '')
    unless value.to_s.match?(/\A\d{4}-\d{2}-\d{2}\z/)
      error(path, 'must be an ISO YYYY-MM-DD date')
      return
    end
    parsed = Date.iso8601(value.to_s)
    error(path, 'future dates cannot certify research progress or recorded evidence') if parsed > @today
    parsed
  rescue Date::Error
    error(path, 'invalid calendar date')
    nil
  end

  def text_list(value, path, nonempty: false)
    list = array(value, path)
    error(path, 'must not be empty') if nonempty && list.empty?
    list.each { |item| error(path, 'items must be nonempty text') unless item.is_a?(String) && !item.strip.empty? }
    list
  end

  def url(value, path, internal: false, optional: false)
    return if optional && (value.nil? || value == '')
    unless value.is_a?(String) && !value.empty?
      error(path, 'URL is required')
      return
    end
    if internal && value.start_with?('/') && !value.start_with?('//')
      route = value.split(/[?#]/).first
      error(path, 'unknown internal route or hard-coded baseurl') unless @routes.include?(route)
      return
    end
    parsed = URI.parse(value)
    host = parsed.host.to_s
    valid = parsed.scheme == 'https' && host.include?('.') && !parsed.userinfo
    private_host = host.match?(/(?:\A|\.)(?:localhost|local|internal|test|invalid|example)(?:\.|\z)/i)
    begin
      ip = IPAddr.new(host.delete_prefix('[').delete_suffix(']'))
      private_host ||= ip.private? || ip.loopback? || ip.link_local? || ip.to_i.zero?
    rescue IPAddr::InvalidAddressError
      # DNS host; URL existence and public permission still require human review.
    end
    error(path, 'must be a public HTTPS URL without credentials or placeholder host') unless valid && !private_host
  rescue URI::InvalidURIError
    error(path, 'malformed URL')
  end

  def image(value, path, prefix: '/assets/images/')
    unless value.is_a?(String) && value.start_with?(prefix) && value.match?(/\.(?:png|webp|jpe?g|svg)\z/i) && !value.split('/').include?('..')
      error(path, 'must be a local approved image path under the expected assets directory')
      return
    end
    full = File.join(@root, value.delete_prefix('/'))
    error(path, 'referenced image does not exist') unless File.file?(full)
    if File.exist?(full) && !File.realpath(full).start_with?(@root + '/')
      error(path, 'image resolves outside the website directory')
    end
  end

  def links(value, path, nonempty: false)
    list = array(value, path)
    error(path, 'evidence must not be empty') if nonempty && list.empty?
    list.each_with_index do |item, i|
      item = object(item, "#{path}[#{i}]")
      required(item, %w[title url], path)
      url(item['url'], path, internal: true)
    end
  end

  def scan(text, path, published: true)
    if published && text.match?(/REPLACE WITH|SXX-XXX|<GITHUB_USERNAME>|\bTODO\b|\bTBD\b/i)
      error(path, 'placeholder content cannot be published')
    end
    # Heuristics only: never print the matching potentially sensitive content.
    if text.match?(/(?:sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9]{20,}|AKIA[A-Z0-9]{16}|-----BEGIN (?:RSA |OPENSSH |EC )?PRIVATE KEY-----)/)
      error(path, 'possible credential detected; manual review required')
    end
    if text.match?(%r{(?:[A-Za-z]:\\(?:Users|Windows)\\|/(?:home|Users)/[^\s/]+/|https?://(?:localhost|127\.|10\.\d+\.|192\.168\.|172\.(?:1[6-9]|2\d|3[01])\.))}i)
      error(path, 'possible private path or internal endpoint detected')
    end
  end

  def documents(collection)
    paths = Dir.glob(File.join(@root, "_#{collection}", '**', '*'), File::FNM_DOTMATCH).select { |p| File.file?(p) }
    paths.filter_map do |full|
      next if File.basename(full) == '.gitkeep'
      path = full.delete_prefix(@root + '/')
      unless File.extname(full) == '.md' && File.dirname(full) == File.join(@root, "_#{collection}")
        error(path, 'collections accept only top-level Markdown records')
        next
      end
      name = File.basename(full, '.md')
      error(path, 'filename must be a URL-safe identifier') unless name.match?(/\A[A-Za-z0-9][A-Za-z0-9_-]*\z/)
      text = File.read(full, encoding: 'UTF-8')
      match = text.match(/\A---\r?\n(.*?)\r?\n---(?:\r?\n|\z)(.*)\z/m)
      unless match
        error(path, 'missing YAML front matter')
        next
      end
      data = object(yaml(match[1], path), path)
      boolean(data, 'published', path)
      scan(text, path, published: data['published'] == true)
      %w[permalink output render_with_liquid].each { |key| error(path, "#{key} overrides are not allowed") if data.key?(key) }
      expected_layout = collection == 'cases' ? 'case' : 'update'
      error(path, 'unexpected layout') if data.key?('layout') && data['layout'] != expected_layout
      # Commentary is Markdown prose; active HTML and Liquid are forbidden.
      error(path, 'commentary must not contain HTML or Liquid') if match[2].match?(/<\/?[a-z!]|\{%|\{\{/i)
      @routes << (collection == 'cases' ? "/cases/#{name}/" : "/progress/updates/#{name}/") if data['published'] == true
      [path, data]
    end
  end

  def unique(records, key, path)
    values = records.map { |record| record[key] }.compact
    error(path, "duplicate #{key}") if values.uniq.size != values.size
  end

  def validate
    data = {}
    Dir.glob(File.join(@root, '_data', '*.{yml,yaml}')).each do |full|
      path = full.delete_prefix(@root + '/')
      text = File.read(full, encoding: 'UTF-8')
      scan(text, path)
      data[File.basename(full, '.*')] = yaml(text, path)
    end
    cases = documents('cases')
    updates = documents('updates')
    unique(cases.map(&:last), 'case_id', '_cases')
    cases.each do |path, c|
      boolean(c, 'approved_for_publication', path)
      boolean(c, 'output_is_excerpt', path)
      boolean(c, 'prompt_is_excerpt', path) if c.key?('prompt_is_excerpt')
      required(c, %w[case_id title scenario_id requester_role attack_strategy target_information_category prompt agent_output], path)
      enum(c, 'intended_exposure_type', INTENDED, path)
      enum(c, 'observed_exposure_type', OBSERVED, path)
      enum(c, 'outcome', OUTCOMES, path)
      date(c['run_date'], "#{path}.run_date")
      if c['published'] == true
        error(path, 'published cases require approved_for_publication: true') unless c['approved_for_publication'] == true
        if c['show_provenance'] == false
          error(path, 'a case without displayed provenance requires evaluation_verified: true') unless c['evaluation_verified'] == true
          %w[prompt agent_output].each do |field|
            expected = Digest::SHA256.hexdigest(c[field].to_s)
            error(path, "#{field}_sha256 does not match the complete text") unless c["#{field}_sha256"] == expected
          end
        else
          required(c, %w[evidence_reference], path)
        end
      end
      boolean(c, 'show_provenance', path) if c.key?('show_provenance')
      boolean(c, 'evaluation_verified', path) if c.key?('evaluation_verified')
      if c.key?('direct_disclosure_count')
        count = c['direct_disclosure_count']
        error(path, 'direct_disclosure_count must be a positive integer for direct exposure') unless count.is_a?(Integer) && count > 0 && c['outcome'] == 'leakage_observed' && c['observed_exposure_type'] == 'direct_exposure'
      end
      if c.key?('protected_fact_highlights')
        spans = array(c['protected_fact_highlights'], "#{path}.protected_fact_highlights")
        if !spans.empty? && (c['outcome'] != 'leakage_observed' || c['observed_exposure_type'] != 'direct_exposure')
          error(path, 'protected-fact highlights require observed direct disclosure')
        end
        cursor = 0
        output = c['agent_output'].to_s
        spans.each do |entry|
          span = object(entry, "#{path}.protected_fact_highlights")
          first, last = span.values_at('start', 'end')
          unless first.is_a?(Integer) && last.is_a?(Integer) && first >= cursor && last > first && last <= output.length
            error(path, 'highlight ranges must be ordered, nonoverlapping and inside agent_output')
            next
          end
          error(path, 'highlight text must match its exact agent_output range') unless span['text'].is_a?(String) && span['text'] == output[first...last]
          cursor = last
        end
      end
      if c['outcome'] == 'leakage_observed' && %w[none unknown].include?(c['observed_exposure_type'])
        error(path, 'observed leakage requires a known observed exposure type')
      end
      if c['outcome'] == 'no_leakage_observed' && !%w[none unknown].include?(c['observed_exposure_type'])
        error(path, 'no-leakage outcome conflicts with observed exposure')
      end
    end

    platform = object(data['platform'], '_data/platform.yml')
    required(platform, %w[title summary], 'platform')
    url(platform['github_url'], 'platform.github_url', optional: true)
    if platform['github_url'].to_s != '' && URI.parse(platform['github_url']).host != 'github.com'
      error('platform.github_url', 'must identify the verified public GitHub repository')
    end
    text_list(platform.fetch('capabilities', []), 'platform.capabilities')
    unless platform['architecture_image'].to_s.empty?
      image(platform['architecture_image'], 'platform.architecture_image', prefix: '/assets/images/platform/')
      required(platform, %w[architecture_alt architecture_caption], 'platform')
    end
    array(platform['screenshots'], 'platform.screenshots').each do |shot|
      shot = object(shot, 'screenshot')
      required(shot, %w[src alt caption], 'screenshot')
      image(shot['src'], 'screenshot.src', prefix: '/assets/images/platform/')
      date(shot['captured_at'], 'screenshot.captured_at')
    end

    figures = array(data['figures'], '_data/figures.yml').map { |f| object(f, 'figure') }
    unique(figures, 'id', 'figures')
    figures.each do |f|
      required(f, %w[id title category image alt caption scope source_note], 'figure')
      image(f['image'], 'figure.image', prefix: '/assets/images/figures/')
      if f.key?('sample_size') && !(f['sample_size'].is_a?(Integer) && f['sample_size'] >= 0)
        error('figure.sample_size', 'must be a nonnegative integer when supplied')
      end
    end

    milestones = object(data['milestones'], '_data/milestones.yml')
    items = array(milestones['items'], 'milestones.items').map { |m| object(m, 'milestone') }
    cutoff = date(milestones['as_of'], 'milestones.as_of', required: !items.empty?)
    required(milestones, %w[summary], 'milestones') if cutoff
    error('milestones', 'a dated snapshot requires evidence-backed milestone items') if cutoff && items.empty?
    unique(items, 'id', 'milestones')
    items.each do |m|
      path = "milestone #{m['id']}"
      required(m, %w[id title], path)
      error(path, 'id must be URL safe') unless m['id'].to_s.match?(/\A[a-zA-Z0-9_-]+\z/)
      enum(m, 'status', %w[planned in_progress completed], path)
      starts = date(m['start_date'], "#{path}.start_date")
      ends = date(m['completed_at'], "#{path}.completed_at")
      verified = date(m['last_verified_at'], "#{path}.last_verified_at")
      [starts, ends, verified].compact.each { |d| error(path, 'recorded date exceeds snapshot cutoff') if cutoff && d > cutoff }
      error(path, 'completion precedes start') if starts && ends && ends < starts
      error(path, 'only completed milestones may have completed_at') if ends && m['status'] != 'completed'
      text_list(m['achievements'], "#{path}.achievements", nonempty: m['status'] == 'completed')
      text_list(m['next_steps'], "#{path}.next_steps")
      links(m['evidence'], "#{path}.evidence", nonempty: true)
    end
    ids = items.map { |m| m['id'] }
    updates.each do |path, u|
      required(u, %w[title summary], path)
      cutoff = date(u['snapshot_date'], "#{path}.snapshot_date", required: true)
      references = text_list(u['milestone_ids'], "#{path}.milestone_ids", nonempty: u['published'] == true)
      error(path, 'unknown milestone reference') unless (references - ids).empty?
      text_list(u['achievements'], "#{path}.achievements", nonempty: u['published'] == true)
      text_list(u['next_steps'], "#{path}.next_steps")
      links(u['evidence'], "#{path}.evidence", nonempty: u['published'] == true)
      array(u.fetch('corrections', []), "#{path}.corrections").each do |correction|
        correction = object(correction, path)
        required(correction, %w[note], path)
        changed = date(correction['date'], "#{path}.correction.date", required: true)
        error(path, 'correction predates original snapshot') if cutoff && changed && changed < cutoff
      end
    end

    resources = object(data['resources'], '_data/resources.yml')
    array(resources['items'], 'resources.items').each do |r|
      r = object(r, 'resource')
      required(r, %w[title type], 'resource')
      enum(r, 'status', %w[published coming_soon], 'resource')
      url(r['url'], 'resource.url', optional: r['status'] != 'published')
    end
    nav = array(data['navigation'], 'navigation')
    error('navigation', 'must contain exactly the six required routes in order') unless nav.map { |n| n.is_a?(Hash) ? n['url'] : nil } == MAIN_ROUTES
    config = object(yaml(File.read(File.join(@root, '_config.yml')), '_config.yml'), '_config.yml')
    base = config['baseurl']
    error('_config.yml', 'baseurl must be empty or a /path without trailing slash') unless base.is_a?(String) && (base.empty? || base.match?(%r{\A/[\w-]+(?:/[\w-]+)*\z}))
    url(config['url'], '_config.yml.url', optional: true)
    @errors.empty?
  rescue Errno::ENOENT, ArgumentError, URI::InvalidURIError => e
    error('content', "invalid input (#{e.class})")
    false
  end
end

if $PROGRAM_NAME == __FILE__
  validator = ContentValidator.new(ARGV[0] || File.expand_path('..', __dir__))
  if validator.validate
    puts 'Content validation passed. Research authenticity and publication permission still require human review.'
  else
    warn validator.errors.join("\n")
    exit 1
  end
end
