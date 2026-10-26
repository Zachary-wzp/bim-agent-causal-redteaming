# All synthetic content is created outside the repository and removed on exit.
require 'tmpdir'
require 'fileutils'
require 'yaml'
require 'open3'
require 'digest'

root = File.expand_path('..', __dir__)
Dir.mktmpdir('bim-integration-') do |tmp|
  %w[_config.yml _data _layouts _includes _plugins scripts assets index.md platform.md statistics.md resources.md cases progress].each { |name| FileUtils.cp_r("#{root}/#{name}", tmp) }
  FileUtils.mkdir_p(["#{tmp}/_cases", "#{tmp}/_updates"])
  write = ->(name, data) { File.write("#{tmp}/#{name}", data.to_yaml) }
  record = ->(name, data) { File.write("#{tmp}/#{name}", data.to_yaml + "---\n") }
  c = {'published' => true, 'approved_for_publication' => true, 'case_id' => 'QA-001', 'title' => 'QA Alpha — software test only', 'scenario_id' => 'QA-A', 'requester_role' => 'QA role A', 'attack_strategy' => 'QA strategy A', 'intended_exposure_type' => 'direct_exposure', 'observed_exposure_type' => 'none', 'outcome' => 'no_leakage_observed', 'target_information_category' => 'Synthetic software fixture', 'expected_authorized_behavior' => 'Test rendering only', 'short_summary' => 'This is not a research record.', 'output_is_excerpt' => true, 'prompt_is_excerpt' => true, 'redaction_notice' => 'Software-test label only', 'evidence_reference' => 'Software assertions only', 'prompt' => "<script>window.qaInjected = true</script>\n{{ 7 | plus: 8 }}\n" + 'x' * 2000, 'agent_output' => "<&>\nSynthetic test output"}
  marked_output = "😀 <&>\n<script>window.qaOutputInjected = true</script>\n{{ 2 | plus: 3 }}\nSynthetic test output"
  protected_case = c.merge('agent_output' => marked_output, 'observed_exposure_type' => 'direct_exposure', 'outcome' => 'leakage_observed', 'protected_fact_highlights' => [{'start' => 2, 'end' => 5, 'text' => '<&>'}, {'start' => 6, 'end' => marked_output.length, 'text' => marked_output[6..]}])
  record.call('_cases/qa-001.md', protected_case)
  record.call('_cases/qa-002.md', c.merge('case_id' => 'QA-002', 'title' => 'QA Beta — software test only', 'scenario_id' => 'QA-B', 'requester_role' => 'QA role B', 'attack_strategy' => 'QA strategy B', 'intended_exposure_type' => 'indirect_exposure', 'observed_exposure_type' => 'unknown', 'outcome' => 'inconclusive', 'show_provenance' => false, 'evaluation_verified' => true, 'prompt_sha256' => Digest::SHA256.hexdigest(c['prompt']), 'agent_output_sha256' => Digest::SHA256.hexdigest(c['agent_output']), 'evidence_reference' => 'HIDDEN_PROVENANCE_SENTINEL', 'evaluation_method' => 'HIDDEN_METHOD_SENTINEL', 'run_id' => 'HIDDEN_RUN_SENTINEL', 'run_date' => '2019-04-17'))
  record.call('_cases/qa-unpublished.md', c.merge('case_id' => 'QA-PRIVATE', 'published' => false, 'approved_for_publication' => false, 'title' => 'UNPUBLISHED_SENTINEL'))
  evidence = [{'title' => 'QA evidence link', 'url' => '/platform/'}]
  write.call('_data/milestones.yml', {'as_of' => '2020-03-01', 'summary' => 'Software test snapshot', 'items' => [{'id' => 'qa', 'title' => 'QA milestone', 'status' => 'completed', 'start_date' => '2020-01-01', 'completed_at' => '2020-02-01', 'last_verified_at' => '2020-03-01', 'achievements' => ['QA assertion'], 'evidence' => evidence, 'next_steps' => []}]})
  u = {'published' => true, 'snapshot_date' => '2020-01-01', 'title' => 'QA older snapshot', 'summary' => 'Software fixture, not research history', 'milestone_ids' => ['qa'], 'achievements' => ['QA assertion'], 'evidence' => evidence, 'next_steps' => []}
  record.call('_updates/z-old.md', u)
  record.call('_updates/a-new.md', u.merge('snapshot_date' => '2020-03-01', 'title' => 'QA newer snapshot', 'corrections' => [{'date' => '2020-03-02', 'note' => 'QA correction'}]))
  svg = '<svg xmlns="http://www.w3.org/2000/svg" width="400" height="200"><rect width="400" height="200" fill="#edf3f6"/><text x="20" y="100">SOFTWARE TEST ONLY</text></svg>'
  File.write("#{tmp}/assets/images/figures/qa.svg", svg)
  File.write("#{tmp}/assets/images/platform/qa.svg", svg)
  write.call('_data/figures.yml', [{'id' => 'qa', 'title' => 'QA image rendering', 'category' => 'Software test', 'image' => '/assets/images/figures/qa.svg', 'alt' => 'Software assertion image', 'caption' => 'No research data', 'scope' => 'Software test only', 'source_note' => 'Generated in temporary test directory'}])
  platform = YAML.load_file("#{tmp}/_data/platform.yml")
  platform['screenshots'] = [{'title' => 'QA image', 'src' => '/assets/images/platform/qa.svg', 'alt' => 'Software assertion', 'caption' => 'Not a platform screenshot', 'version' => 'QA', 'captured_at' => '2020-01-01'}]
  write.call('_data/platform.yml', platform)
  build = ['bundle', 'exec', 'jekyll', 'build', '--source', tmp, '--destination', "#{tmp}/_site"]
  output, status = Open3.capture2e(*build, chdir: root)
  raise output unless status.success?
  raise 'Unpublished case leaked' if File.exist?("#{tmp}/_site/cases/qa-unpublished/index.html")
  html = File.read("#{tmp}/_site/cases/qa-001/index.html")
  raise 'Escaping failed' unless html.include?('&lt;script&gt;') && html.include?('{{ 7 | plus: 8 }}') && !html.include?('<script>window.qaInjected')
  raise 'Highlight escaping failed' unless html.include?('>&lt;&amp;&gt;</mark>') && html.include?('&lt;script&gt;window.qaOutputInjected') && !html.include?('<script>window.qaOutputInjected')
  raise 'Secret sentinel leaked' if Dir.glob("#{tmp}/_site/**/*.html").any? { |file| File.read(file).include?('UNPUBLISHED_SENTINEL') }
  hidden = File.read("#{tmp}/_site/cases/qa-002/index.html")
  %w[HIDDEN_PROVENANCE_SENTINEL HIDDEN_METHOD_SENTINEL HIDDEN_RUN_SENTINEL 2019-04-17].each do |sentinel|
    raise 'Hidden provenance leaked' if Dir.glob("#{tmp}/_site/**/*.html").any? { |file| File.read(file).include?(sentinel) }
  end
  raise 'Hidden provenance label leaked' if hidden.match?(/Public run ID|Public evidence reference|Run date|Evaluation method/)
  home = File.read("#{tmp}/_site/index.html")
  history = File.read("#{tmp}/_site/progress/index.html")
  raise 'Latest progress is not date-sorted' unless home.include?('QA newer snapshot') && !home.include?('QA older snapshot')
  raise 'History is not date-sorted' unless history.index('QA newer snapshot') < history.index('QA older snapshot')
  raise 'Static output check failed' unless system('python3', "#{root}/scripts/check_site.py", "#{tmp}/_site")
  if ENV['PLAYWRIGHT_MODULE']
    raise 'Browser fixture check failed' unless system('node', "#{root}/scripts/browser_check.cjs", "#{tmp}/_site", '--fixtures', chdir: root)
  end
  record.call('_cases/qa-blocked.md', c.merge('case_id' => 'QA-BLOCKED', 'approved_for_publication' => false))
  output, status = Open3.capture2e(*build, chdir: root)
  raise 'Direct Jekyll build bypassed the gate' if status.success? || !output.include?('approved_for_publication')
  File.unlink("#{tmp}/_cases/qa-blocked.md")
  output, status = Open3.capture2e(*(build + ['--unpublished']), chdir: root)
  raise 'Unpublished override was not blocked' if status.success? || !output.include?('unpublished research content')
  output, status = Open3.capture2e(*(build + ['--baseurl', '']), chdir: root)
  raise output unless status.success?
  raise 'Root-baseurl links failed' unless system('python3', "#{root}/scripts/check_site.py", "#{tmp}/_site", '--baseurl', '')
  puts 'Integration checks passed: isolated collections, escaping, hidden drafts/provenance, snapshot order, image links and build gates.'
end
