# Local verification report

Initial verification: 2026-10-22. Release preparation: 2026-10-26 (Asia/Shanghai).
These dates describe website development only, not research milestones or snapshots.

## Completed implementation

Phases 0–4 were implemented in order. The site includes Home, BIM Agent, Case
Studies, Statistics, Project Progress and Resources. Case and update detail pages
are generated from their collections. All data-dependent sections have empty states.

The current local display inventory is **16 cases, 1 homepage research architecture
schematic, 0 platform screenshots, 0 evaluated-platform architecture images,
0 statistical figures, 0 milestones, 0 research updates and 0 external
research resource links**. The case collection covers 13 distinct prompts; repeated
requests retain separate final responses. Every included run has an evaluated,
explicit direct disclosure in its final response. Prompts and complete final
answers are preserved without redaction. Source metadata is not displayed.
The homepage architecture follows the user-specified multi-agent design and is
explicitly labeled as a design schematic. It shows a Coordinator Agent routing
requests by user role to ARC, STR, MEP and COST agents, then combining responses.
The full-dataset GitHub entry is reserved as Coming soon with a blank URL.

The Home hero uses a centered text layout with the research title, introduction
and navigation links. Its case-output excerpt has been removed. The architecture
is in the independent Research Design section after Research Workflow; all 16
complete cases and the existing Featured Cases cards remain available.

Only website files were changed. On 2026-10-26 the user authorized publication to
Zachary-wzp/bim-agent-privacy-website. The six pages and current 16-case collection
are the release scope; source metadata remains hidden.

## Commands and outcomes

Environment: Ubuntu 24.04 in WSL, Ruby 3.2.3, Bundler 2.6.9, Jekyll 4.4.1.
Browser QA: Playwright 1.58.2, Chromium 145.0.7632.6. Node is only a QA dependency.

| Check | Outcome |
| --- | --- |
| `bundle exec ruby scripts/validate_content.rb` | Passed with all 16 approved local-display cases |
| `bundle exec ruby tests/content_validation_test.rb` | 44 regression checks passed, including text integrity, hidden provenance, Unicode highlight ranges and rejection of stale/overlapping annotations |
| `bundle exec ruby tests/output_rendering_test.rb` | 19 Markdown rendering checks passed: structure, exact occurrence highlighting, formatting boundaries, inert HTML/Liquid, code whitespace and ambiguity rejection |
| `JEKYLL_ENV=production bundle exec jekyll build --destination .qa/production` | Passed; six primary pages and 16 case detail pages generated |
| `python3 scripts/check_site.py .qa/production` | All 22 HTML pages, local links/anchors, assets, alt text and excluded source files passed |
| `node scripts/browser_check.cjs .qa/production` with Playwright configured | 122 checks passed on the populated website, including Markdown tables, original text, highlight styling/navigation and exact clipboard results |
| `bundle exec ruby tests/integration_test.rb` with Playwright configured | Temporary populated site: 10 HTML routes, 33 browser checks, publication gates and root/project baseurl checks passed |
| Import fidelity | 32/32 prompt and output texts exactly matched; UTF-8 SHA-256 values retained in each website record |
| Presentation-scope scan | All 22 HTML pages omit source identifiers, private source paths and provenance metadata |
| Live preview on port 4000 | All 22 routes returned HTTP 200; 16 cases displayed; 32/32 original-text hashes matched; no JavaScript errors |
| Highlighted live preview | All 16 case pages and 58 marked passages verified; 32/32 original-text hashes unchanged; text/background contrast 7.14:1 |
| Case-detail Markdown live preview | 16 case details contain 20 rendered tables and 58 highlights; 32/32 original-text hashes and 16/16 copied-output hashes matched |
| Case-to-case navigation live preview | All 16 details checked at 360/768/1440 px: top/bottom links and positions, first/last boundaries, 45 next and 45 previous clicks, keyboard activation and 15 next clicks without JavaScript passed |
| Research architecture live preview | User, coordinator and all four specialists; request/answer and delegation/result arrows; responsive layout at 320/360/768/1024/1440 px; no content overflow; no-JavaScript display passed |
| Text-only homepage hero live preview | 320/360/768/1440 px: excerpt absent, centered title/introduction/links, no horizontal overflow, independent Research Design retained, all 16 cases accessible |
| Native JS syntax checks | Passed for site navigation/copy and Case Explorer scripts |
| Workflow YAML syntax review | Parsed successfully; build precedes gated deployment; no remote run performed |

Browser tests exercised all six pages and all 16 case details at **360, 768 and
1440 px**. No horizontal
overflow, JavaScript errors or failing local resource requests were observed.
Screenshots were visually reviewed, including a mobile case detail, the longest
output at desktop width and the populated tablet Case Explorer. Keyboard menu
activation, Escape, visible focus and no-JavaScript navigation were checked.
All 16 prompts, all 16 original-output disclosures and all 32 clipboard results
matched the complete website records. The formatted view intentionally renders
Markdown syntax as headings, tables, lists, emphasis and code. Every available
scenario, role, strategy, intended-exposure and
outcome filter was tested, together with combined filters, search, no-match state,
reset, Home count and the non-clickable GitHub dataset placeholder.

All 16 cases include protected-fact highlighting: 58 passages cover the 67
per-run facts recorded in their final direct-disclosure assessments. Coverage was
checked before annotations were written. No assessment result or prompt/output text
was changed. Highlighted passages are not counted as distinct facts. Browser tests
verify exact marked substrings, foreground/background/underline, keyboard cycling
through every passage and back to the first, visibility inside the output panel,
and server-rendered marks with JavaScript disabled. Clipboard comparisons still
cover the full unmodified text.
Focused screenshots of highlighted mobile and desktop output panels were visually
reviewed at 360 and 1440 px after using Next highlight. They are stored under
`.qa/screenshots/highlights-*` and are excluded from publication.
The Markdown revision was visually reviewed in mobile and desktop screenshots,
including a two-column table, commercial comparison tables and the longest output.
Focused captures are under `.qa/screenshots/markdown-*`, also excluded from publication.

Case details now include Previous case / Next case links at both ends, ordered by
case ID exactly as in Case Studies. Only published, approved cases enter navigation.
First/last boundaries are non-clickable, and the current position is shown. Focused
live-browser verification covered 48 case layouts, continuous traversal in both
directions, keyboard activation and a full forward traversal without JavaScript.
Mobile and desktop navigation screenshots were visually reviewed; captures are
under `.qa/screenshots/case-navigation-*` and results in `.qa/case-navigation.json`.
The production build, 22-page static check, 122 browser checks and isolated
integration checks were rerun after this addition and passed. Existing hidden-draft
checks also passed with the navigation included.

The homepage architecture replacement was visually reviewed at desktop and mobile
widths. The content validator, production build, 22-page static checks, 122 browser
checks and isolated integration checks all passed after replacement. Focused
captures are in `.qa/screenshots/architecture-*`, with live layout check results
in `.qa/architecture-check.json`. No research-project files or case records changed.

Isolated fixture checks cover each filter, combined filters, case-insensitive
ID/title search, no-match state, reset, result counts, detail navigation, a long
unbroken prompt, HTML/Liquid escaping, clipboard success and denied-permission
fallback, latest-update sorting by date, figure links, hidden drafts, direct-build
approval enforcement and rejection of `--unpublished`. Sentinel fields also verify
that hidden provenance is absent from every generated page.
Highlight fixtures include an emoji before the first range, HTML metacharacters,
a literal script and Liquid syntax; they remain inert, correctly escaped text.
Markdown checks cover tables immediately after paragraphs, literal pipes that are
not tables, repeated protected values, marks crossing emphasis nodes, code literals,
HTML entities, blocked unsafe links/embedded elements, and conflicting heading IDs.
Denied clipboard access opens the original Markdown disclosure and selects the exact
source. The no-JavaScript check also opens and reads that disclosure.

The fixture records are synthetic software inputs, not research data. They are
generated only under an OS temporary directory and removed on completion. The
production case collection contains only the 16 approved display records.
Browser screenshots under `.qa/screenshots/` contain the actual website and are
excluded from both Git and `_site`.

## Issues found and resolved

The hero excerpt was removed at the user's request, together with its dedicated
configuration, template, styles and excerpt-only renderer/tests. The remaining
19 Markdown checks, content validation, production build, all 22 static routes
and 122 browser checks passed. Desktop and mobile captures of the centered hero
are in `.qa/screenshots/text-hero-*`. Earlier excerpt captures are historical QA
artifacts, excluded from the website.

- Installed the missing Ruby/Bundler environment so Jekyll could actually build.
- Installed missing Chromium system libraries to complete browser QA in WSL.
- Fixed the QA static server's root-route path check, which initially returned 403.
- Fixed a missing space between two overview title phrases at the mobile breakpoint.
- Made optional repository, architecture, snapshot and citation sections handle
  omitted values as well as empty strings.
- Separated the final production output check from the active preview output:
  Jekyll serve injects a localhost HTTP canonical URL, while production checks
  intentionally require HTTPS for configured public links. A separate production
  build under `.qa/production` passed without changing the running preview.
- Normalized the new case filenames to lowercase after browser QA exposed a
  mismatch between filename casing and Jekyll's generated URL casing.
- Extended browser QA to validate populated collections instead of assuming zero
  cases, including exact text and clipboard checks for each imported run.
- Restarted the local preview after import so the served pages include all 16 cases.
- Added Markdown rendering without changing any case prompt, output or highlight
  range. Wide tables remain inside horizontally scrollable regions on mobile.
- Corrected the parser's handling of literal HTML so it cannot stall, and required
  a table separator to prevent ordinary pipe characters or Liquid from becoming tables.
- Kept exact source copying separate from formatted display; clipboard fallback
  opens and selects the complete original Markdown.
- Preserved repeated spaces and indentation in highlighted code. Rendering now
  verifies that inserting highlights does not change any displayed text.

## Limits and remaining review

- Release workflow and deployment results are recorded by GitHub Actions in
  Zachary-wzp/bim-agent-privacy-website. Deployment remains gated by the repository
  variable `PAGES_DEPLOYMENT_APPROVED` and successful validation.
- The confirmed public origin is `https://zachary-wzp.github.io`, with project path
  `/bim-agent-privacy-website`. External research resource URLs remain empty; their
  reachability cannot be verified until supplied.
- Automated tests cannot grant release permission. The user approved the case
  selection, display treatment and website publication. Screenshots, architecture, statistical figures,
  research milestones/history, real resource URLs and citation material remain to
  be supplied and reviewed; empty states remain in place.
- Browser verification used Chromium; Safari/Firefox and assistive-technology
  testing were not performed.

## Preview

```bash
bundle exec jekyll serve --host 127.0.0.1 --port 4000
```

Preview: <http://127.0.0.1:4000/bim-agent-privacy-website/>.
Case Explorer: <http://127.0.0.1:4000/bim-agent-privacy-website/cases/>.
The preview is local-only. If the server is stopped, restart with the command above.
