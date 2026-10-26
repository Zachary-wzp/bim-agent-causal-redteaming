# Synthetic software fixtures live only in a temporary directory, never _cases.
require 'tmpdir'
require 'fileutils'
require_relative '../scripts/validate_content'

root = File.expand_path('..', __dir__)
checks = 0
Dir.mktmpdir('bim-content-tests-') do |tmp|
  write = ->(name, data) { FileUtils.mkdir_p(File.dirname("#{tmp}/#{name}")); File.write("#{tmp}/#{name}", data.to_yaml) }
  reset = lambda do
    FileUtils.rm_rf(Dir.glob("#{tmp}/*", File::FNM_DOTMATCH).reject { |p| %w[. ..].include?(File.basename(p)) })
    FileUtils.cp_r("#{root}/_data", tmp)
    FileUtils.cp("#{root}/_config.yml", tmp)
    FileUtils.mkdir_p("#{tmp}/_cases")
    FileUtils.mkdir_p("#{tmp}/_updates")
  end
  case_data = {
    'published' => true, 'approved_for_publication' => true, 'case_id' => 'QA-001',
    'title' => 'Software validation fixture', 'scenario_id' => 'QA', 'requester_role' => 'Fixture role',
    'attack_strategy' => 'Fixture strategy', 'target_information_category' => 'Synthetic test text',
    'intended_exposure_type' => 'direct_exposure', 'observed_exposure_type' => 'none',
    'outcome' => 'no_leakage_observed', 'output_is_excerpt' => false,
    'evidence_reference' => 'Software test only; not research evidence',
    'prompt' => '<script>window.qaInjected = true</script>\n{{ 7 | plus: 8 }}',
    'agent_output' => 'Synthetic software assertion text; not a research result'
  }
  put_case = ->(data, name = 'qa') { File.write("#{tmp}/_cases/#{name}.md", data.to_yaml + "---\n") }
  verify = lambda do |name, expected, &change|
    reset.call
    change.call if change
    validator = ContentValidator.new(tmp)
    result = validator.validate
    raise "#{name}: expected #{expected}, got #{result}: #{validator.errors.join('; ')}" unless result == expected
    checks += 1
    puts "PASS #{name}"
  end
  verify.call('empty approved-content inventory', true)
  verify.call('approved case schema', true) { put_case.call(case_data) }
  verify.call('unpublished safe record', true) { put_case.call(case_data.merge('published' => false, 'approved_for_publication' => false)) }
  verify.call('publication approval gate', false) { put_case.call(case_data.merge('approved_for_publication' => false)) }
  verify.call('string flags are not booleans', false) { put_case.call(case_data.merge('published' => 'true')) }
  verify.call('duplicate case IDs', false) { put_case.call(case_data); put_case.call(case_data, 'qa2') }
  verify.call('invalid exposure enum', false) { put_case.call(case_data.merge('intended_exposure_type' => 'success')) }
  verify.call('intent is not observed leakage', false) { put_case.call(case_data.merge('outcome' => 'leakage_observed')) }
  verify.call('no leakage contradicts observed type', false) { put_case.call(case_data.merge('observed_exposure_type' => 'direct_exposure')) }
  verify.call('missing prompt', false) { put_case.call(case_data.merge('prompt' => '')) }
  verify.call('placeholder publication', false) { put_case.call(case_data.merge('title' => 'REPLACE WITH REAL TITLE')) }
  verify.call('missing provenance', false) { put_case.call(case_data.merge('evidence_reference' => '')) }
  without_provenance = case_data.reject { |key, _| key == 'evidence_reference' }.merge('show_provenance' => false, 'evaluation_verified' => true, 'prompt_sha256' => Digest::SHA256.hexdigest(case_data['prompt']), 'agent_output_sha256' => Digest::SHA256.hexdigest(case_data['agent_output']))
  verify.call('verified case with provenance display disabled', true) { put_case.call(without_provenance) }
  verify.call('hidden provenance still requires verified evaluation', false) { put_case.call(without_provenance.merge('evaluation_verified' => false)) }
  verify.call('prompt text integrity', false) { put_case.call(without_provenance.merge('prompt' => 'changed text')) }
  verify.call('output text integrity', false) { put_case.call(without_provenance.merge('agent_output' => 'changed text')) }
  verify.call('hidden provenance does not bypass publication approval', false) { put_case.call(without_provenance.merge('approved_for_publication' => false)) }
  verify.call('direct disclosure count cannot be zero', false) { put_case.call(case_data.merge('observed_exposure_type' => 'direct_exposure', 'outcome' => 'leakage_observed', 'direct_disclosure_count' => 0)) }
  highlighted = case_data.merge('agent_output' => '😀 x <&> x', 'observed_exposure_type' => 'direct_exposure', 'outcome' => 'leakage_observed', 'protected_fact_highlights' => [{'start' => 4, 'end' => 7, 'text' => '<&>'}, {'start' => 8, 'end' => 9, 'text' => 'x'}])
  verify.call('Unicode highlight offsets and repeated text', true) { put_case.call(highlighted) }
  verify.call('stale highlight text', false) { put_case.call(highlighted.merge('agent_output' => '😀 x NEW x')) }
  verify.call('highlight outside output', false) { put_case.call(highlighted.merge('protected_fact_highlights' => [{'start' => 8, 'end' => 99, 'text' => 'x'}])) }
  verify.call('negative highlight offset', false) { put_case.call(highlighted.merge('protected_fact_highlights' => [{'start' => -1, 'end' => 1, 'text' => '😀'}])) }
  verify.call('overlapping highlights', false) { put_case.call(highlighted.merge('protected_fact_highlights' => [highlighted['protected_fact_highlights'].first] * 2)) }
  verify.call('unordered highlights', false) { put_case.call(highlighted.merge('protected_fact_highlights' => highlighted['protected_fact_highlights'].reverse)) }
  verify.call('empty highlight range', false) { put_case.call(highlighted.merge('protected_fact_highlights' => [{'start' => 4, 'end' => 4, 'text' => ''}])) }
  verify.call('highlight offset type', false) { put_case.call(highlighted.merge('protected_fact_highlights' => [{'start' => '4', 'end' => 7, 'text' => '<&>'}])) }
  verify.call('highlight collection type', false) { put_case.call(highlighted.merge('protected_fact_highlights' => 'invalid')) }
  verify.call('highlight entry type', false) { put_case.call(highlighted.merge('protected_fact_highlights' => ['invalid'])) }
  verify.call('highlights require observed disclosure', false) { put_case.call(highlighted.merge('outcome' => 'no_leakage_observed', 'observed_exposure_type' => 'none')) }
  verify.call('impossible calendar date', false) { put_case.call(case_data.merge('run_date' => '2026-02-30')) }
  verify.call('future run date', false) { put_case.call(case_data.merge('run_date' => '2999-01-01')) }
  verify.call('Liquid override', false) { put_case.call(case_data.merge('render_with_liquid' => true)) }
  verify.call('route override', false) { put_case.call(case_data.merge('permalink' => '/')) }
  verify.call('duplicate YAML key', false) { File.write("#{tmp}/_cases/qa.md", case_data.to_yaml + "published: false\n---\n") }
  verify.call('unsafe YAML object', false) { File.write("#{tmp}/_data/figures.yml", '--- !ruby/object:Object {}') }
  verify.call('malformed YAML', false) { File.write("#{tmp}/_data/figures.yml", '[unfinished') }
  verify.call('raw collection file', false) { File.write("#{tmp}/_cases/private.txt", 'not allowed') }
  verify.call('active commentary HTML', false) { put_case.call(case_data); File.open("#{tmp}/_cases/qa.md", 'a') { |f| f.puts('<script>alert(1)</script>') } }
  verify.call('credential-like token', false) { put_case.call(case_data.merge('prompt' => 'sk-' + 'a' * 30)) }
  verify.call('private path', false) { put_case.call(case_data.merge('evidence_reference' => '/home/test/private/run')) }
  verify.call('missing image', false) { p = YAML.load_file("#{tmp}/_data/platform.yml"); p['screenshots'] = [{'src' => '/assets/images/platform/missing.png', 'alt' => 'QA', 'caption' => 'QA'}]; write.call('_data/platform.yml', p) }
  verify.call('unsafe resource URL', false) { write.call('_data/resources.yml', {'items' => [{'title' => 'QA', 'type' => 'code', 'status' => 'published', 'url' => 'javascript:alert(1)'}]}) }
  verify.call('future snapshot without evidence', false) { File.write("#{tmp}/_updates/qa.md", {'published' => true, 'title' => 'QA', 'summary' => 'QA', 'snapshot_date' => '2999-01-01', 'milestone_ids' => [], 'achievements' => [], 'evidence' => [], 'next_steps' => []}.to_yaml + "---\n") }
  verify.call('unsupported milestone completion', false) { write.call('_data/milestones.yml', {'as_of' => '2020-01-01', 'summary' => 'QA', 'items' => [{'id' => 'qa', 'title' => 'QA', 'status' => 'completed', 'achievements' => [], 'next_steps' => [], 'evidence' => []}]}) }
end
puts "#{checks} content validation checks passed."
