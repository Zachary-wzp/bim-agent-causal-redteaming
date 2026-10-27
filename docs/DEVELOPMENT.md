# Website development and maintenance

[Back to the research entry page](../README.md).

English-first static research showcase. Built with Jekyll 4, Markdown/YAML,
and native HTML, CSS and JavaScript. This website does not execute a BIM Agent.

## Content inventory (Phase 0)

The starting directory contained only the execution plan, with no existing
website or Git repository. No approved research materials were provided.
The original execution plan is preserved locally and excluded from this repository.

The initial implementation awaited verified material. Still needed:

- BIM Agent GitHub URL, capability descriptions and architecture diagram.
- Actual platform screenshots, captions, versions and capture dates.
- Additional reviewed cases, if the selected collection is expanded.
- Verified statistical figures with scope, sample size and limitations.
- Research milestone statuses, evidence and dated progress snapshots.
- Public code, paper, dataset and supplementary links; verified citation text.

Initial content counts: **0 cases, 0 screenshots, 0 statistical figures,
0 progress updates**. Missing materials use empty states. Website development
is never recorded as research progress.

## Website content

The site now includes **16 case pages** from **13 distinct prompts**, selected for
explicit direct disclosure in the final answer. Each run has a separate page with
its full prompt, full final output, requester role, strategy, outcome and evaluated
disclosure count. User-authorized display preserves the text without redaction and
omits provenance. Exact text hashes and browser comparisons guard against changes.
Protected facts in each final output are highlighted with dark red text, a pale
background and an underline. Next highlight navigates long answers; copying keeps
the original Markdown text. Outputs render headings, tables, lists, emphasis and
code, with horizontally scrollable tables. View original Markdown expands the
unchanged source. Formatted outputs and highlights also work without JavaScript.

Case details have Previous case / Next case navigation at the top and bottom,
with the current position in the approved collection. Links follow the Case
Studies list's case-ID order; the first and last cases show unavailable directions.
Case navigation works without JavaScript and adapts to mobile screens.

The Home and Case Studies counts reflect these 16 displayed runs. Platform screenshots,
evaluated-platform architecture images, statistical figures and research progress remain empty until
verified material is supplied. The Resources page reserves **Full Research Dataset
on GitHub** with **Coming soon** and no guessed URL. Only the website project is
included in this repository; the research project is maintained separately.

## Local preview (WSL / Linux)

Tested with Ruby 3.2.3, Bundler 2.6.9 and Jekyll 4.4.1. Ruby 3.2+ and Python 3
are needed for the full validation commands. Node is optional, for browser QA only.

```bash
cd bim-agent-sensitive-information
bundle config set --local path vendor/bundle
bundle install
bundle exec ruby scripts/validate_content.rb
bundle exec jekyll serve --host 127.0.0.1 --port 4000
```

Open <http://localhost:4000/bim-agent-sensitive-information/>. Stop with Ctrl+C.
Use your existing checkout directory if its local name differs from the repository name.
Run these commands inside Ubuntu / WSL, not Windows PowerShell. If Ruby is missing,
install `ruby-full build-essential libyaml-dev zlib1g-dev`, then Bundler.
The default preview preserves the GitHub Pages project prefix. To preview at `/`:

```bash
bundle exec jekyll serve --baseurl "" --host 127.0.0.1 --port 4000
```

There is no agent service, API key, database, external font or analytics requirement.
Home's hero presents the research title, introduction and navigation links in a
centered text layout. It contains no case-output excerpt. The full case collection
and the Featured Cases cards remain available below and on the Case Studies page.

The separate `#research-design` section below Research Workflow displays the
user-specified multi-agent research architecture: a user submits
a role and question to a Coordinator Agent, which selects ARC, STR, MEP and COST
specialists according to the user's role and combines their responses. Directional
connectors show requests/delegation and answers/results. The diagram is labeled
as a design schematic; it does not document the evaluated platform's implementation.
Native HTML/CSS and SVG icons keep the text readable, with four specialist columns
when space allows and two on narrow screens. No JavaScript or external assets are needed.

## Content maintenance

See [CONTENT_GUIDE](CONTENT_GUIDE.md) for templates and field definitions,
and [PUBLICATION_CHECKLIST](PUBLICATION_CHECKLIST.md) before any release.

| Content | Edit here |
| --- | --- |
| Shared platform repository URL, capabilities, architecture, screenshots | `_data/platform.yml` |
| Homepage multi-agent research architecture labels | `_data/research_architecture.yml` |
| Reviewed public cases | `_cases/*.md` |
| Verified statistical figures and their scope | `_data/figures.yml` |
| Current milestone snapshot | `_data/milestones.yml` |
| Dated research history and appended correction notes | `_updates/*.md` |
| Other public resources and citation | `_data/resources.yml` |
| Navigation and site settings | `_data/navigation.yml`, `_config.yml` |

Only safe, approved material belongs in this repository, including unpublished
files. `published: false` is not a privacy boundary for Git history. Examples
belong in documentation; the collections contain no demo research records.
The current case values were confirmed by the user to be non-real sensitive data.
The user authorized publication of this website and its current case selection on
2026-10-26. New research material still requires review before inclusion.

The case list requires both `published: true` and `approved_for_publication: true`.
Validation also runs inside normal Jekyll builds and watch rebuilds, stopping
unapproved publication. Do not bypass it with `--safe` or custom plugin settings;
`--unpublished` is explicitly blocked. Prompts remain escaped plain text; output
Markdown is rendered with raw HTML and executable extensions disabled. Original
output text remains available for inspection and copying. Case/update bodies have
Liquid rendering disabled. No-JavaScript visitors can
still read all public cases and details; JavaScript adds filters, menu and copy controls.

## Validation

```bash
bundle exec ruby scripts/validate_content.rb
bundle exec ruby tests/content_validation_test.rb
bundle exec ruby tests/output_rendering_test.rb
bundle exec ruby tests/integration_test.rb
JEKYLL_ENV=production bundle exec jekyll build --trace
python3 scripts/check_site.py
```

Run the output check against a build, not the files rewritten by `jekyll serve`:
Jekyll supplies a local HTTP canonical origin during serving. If preview is running,
use `JEKYLL_ENV=production bundle exec jekyll build --destination .qa/production`
followed by `python3 scripts/check_site.py .qa/production` to keep it undisturbed.

The content validator checks schemas, duplicate IDs/YAML keys, publication flags,
enums, valid nonfuture dates, evidence references or verified text hashes for cases
without displayed provenance, conflicting outcomes, local image
existence, resource URL schemes and obvious credential/private-path patterns.
The output checker checks all six routes, local links/anchors, image alt text,
baseurl and exclusion of development files. These checks cannot authenticate
research claims, grant publication permission or reliably inspect image pixels.

Tests create synthetic software fixtures in OS temporary directories and remove
them on exit. These fixtures never enter `_cases`, `_updates` or the production
`_site`. No test values are research results.

Optional browser QA (development tooling only):

```bash
npm install --prefix .qa/browser-qa --no-audit --no-fund playwright@1.58.2
.qa/browser-qa/node_modules/.bin/playwright install chromium
# If Chromium reports missing OS libraries, install its dependencies:
# sudo .qa/browser-qa/node_modules/.bin/playwright install-deps chromium
export PLAYWRIGHT_MODULE="$PWD/.qa/browser-qa/node_modules/playwright"
node scripts/browser_check.cjs
bundle exec ruby tests/integration_test.rb
```

Checks run Chromium at 360, 768 and 1440 px, exercise keyboard navigation,
no-JavaScript fallback, all case details, exact rendered/copied text, every available
filter value and isolated content-dependent interactions. Real-site
screenshots are written to ignored `.qa/screenshots/`, not published assets.
See [VERIFICATION](VERIFICATION.md) for the completed local checks.

## Files and implementation phases

Phase 0 inventoried the starting directory. Phase 1 established the six pages,
responsive layout and empty states, then built successfully. Phase 2 implemented
platform and cases, then built successfully. Phase 3 implemented figures and
research progress, then built successfully. Phase 4 added content gates,
regression/browser checks, documentation and the Pages workflow.

`_layouts/` and `_includes/` own presentation. `assets/css/style.css` owns the
responsive theme; `assets/js/case-filter.js` and `site.js` progressively enhance
the static pages. `_plugins/content_gate.rb` calls `scripts/validate_content.rb`.
No front-end compilation is needed. `Gemfile.lock` pins the Ruby dependencies.
`_plugins/protected_fact_highlights.rb` renders output Markdown and projects the
reviewed character ranges in `protected_fact_highlights` onto the displayed text.
Validation rejects stale, overlapping or ambiguous ranges. Prompt and output fields
remain unchanged; the renderer uses the existing bundled kramdown and REXML libraries.

## GitHub Pages publication

Repository: <https://github.com/Zachary-wzp/bim-agent-sensitive-information>.
Website: <https://zachary-wzp.github.io/bim-agent-sensitive-information/>.
The user authorized publication to this repository on 2026-10-26.

Pages uses **GitHub Actions**. The repository variable
`PAGES_DEPLOYMENT_APPROVED=true` enables deployment after validation succeeds.
Pull requests run checks but never deploy. The workflow uses the `github-pages`
environment and only deploys `main`.

For future updates:

1. Edit website content locally and review it in the local preview.
2. Run the validation commands above and check the changed pages.
3. Inspect `git diff` and staged files; keep generated output, dependencies, local
   configuration and `.qa` outside Git.
4. Commit and push to `main`. Follow **Actions → Validate, build and deploy research
   showcase** until both build and deploy succeed.
5. Open the website and verify the changed pages. Keep the repository name and
   configured origin/baseurl unchanged to retain the same public addresses. If the
   repository is renamed, update all public URLs and baseurl-dependent checks before
   deploying at the new address.

The deployment can also be started from **Actions → Run workflow** on `main`.
The full-dataset GitHub placeholder remains separate from the website repository;
replace it only when the actual dataset has an approved URL.

The workflow follows the official
[GitHub Pages custom workflow documentation](https://docs.github.com/en/pages/getting-started-with-github-pages/using-custom-workflows-with-github-pages).
The site uses [Jekyll Collections](https://jekyllrb.com/docs/collections/) for cases
and progress history.
