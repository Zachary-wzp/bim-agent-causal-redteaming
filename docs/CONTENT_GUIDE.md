# Content maintenance guide

Current repository (renamed on 2026-10-27):
[Zachary-wzp/bim-agent-causal-redteaming](https://github.com/Zachary-wzp/bim-agent-causal-redteaming).

界面内容以英文填写。这里的模板只说明字段，**不是实验记录**。仅加入用户已授权
展示的材料，不要擅自导入其他记录。当前 16 个案例已获用户授权展示：
保留完整提问与最终回答、不脱敏、不展示来源。用户已确认其中的敏感值不是现实
敏感数据。用户于 2026-10-26 指定 Zachary-wzp/bim-agent-privacy-website
仓库并授权发布当前网站；新增研究材料仍需按本指南审核。

## 1. Common rules

- Verify authenticity and the user's authorized display scope before copying files.
- Preserve the agreed treatment of identifiers and values. The current 16 cases use
  complete, unredacted text; do not silently rewrite or shorten it.
- Keep real identifiers, values, sample sizes, dates and outcomes traceable to approved records.
- Dates use quoted ISO strings, e.g. `"YYYY-MM-DD"` with the real date substituted.
- Assets use `/assets/images/...` paths without the site baseurl. Templates add `relative_url`.
- External resource links must be public HTTPS URLs; blank unknown URLs stay blank.
- Evidence arrays use `{title, url}` objects. Internal links use `/cases/actual-id/`,
  `/progress/updates/actual-slug/` or another existing site route, without baseurl.
- Markdown bodies may contain ordinary prose; do not add HTML or Liquid. Recorded
  prompts/outputs may contain literal HTML/Liquid; they are never executed. Output
  Markdown formatting is rendered, while raw HTML remains inert text.
- Run validation and a fresh build after changing content. The six page templates
  do not need to change when adding records or images.

## 2. Add a Case

Create `_cases/<verified-case-id>.md` only after the material is approved for inclusion.
Use lowercase filenames, for example `s01-001.md`, to match the generated URL.
The filename determines `/cases/<verified-case-id>/`; `case_id` must be unique.
Use this template from the documentation, replacing every placeholder with verified text.
Set both flags to `true` only after human review. Never publish the template itself.

```yaml
---
layout: case
published: false
approved_for_publication: false
show_provenance: true
case_id: "REPLACE WITH VERIFIED ID"
title: "REPLACE WITH VERIFIED TITLE"
scenario_id: "REPLACE WITH VERIFIED SCENARIO"
requester_role: "REPLACE WITH VERIFIED ROLE"
attack_strategy: "REPLACE WITH VERIFIED STRATEGY"
target_information_category: "REPLACE WITH SAFE CATEGORY, NOT A SECRET VALUE"
intended_exposure_type: "unknown"
observed_exposure_type: "unknown"
outcome: "inconclusive"
expected_authorized_behavior: ""
short_summary: ""
run_id: ""
run_date: ""
evaluation_method: ""
evidence_reference: "REPLACE WITH PUBLICLY SAFE PROVENANCE"
prompt_is_excerpt: false
output_is_excerpt: false
redaction_notice: ""
prompt: |
  REPLACE WITH THE VERIFIED AND APPROVED PROMPT
agent_output: |
  REPLACE WITH THE VERIFIED AND APPROVED AGENT OUTPUT
---

Optional approved provenance notes in Markdown.
```

| Field | Accepted values / meaning |
| --- | --- |
| `intended_exposure_type` | `over_collection`, `direct_exposure`, `indirect_exposure`, `unknown` |
| `observed_exposure_type` | Same values plus `none` |
| `outcome` | `leakage_observed`, `no_leakage_observed`, `inconclusive` |
| `evidence_reference` | Required when provenance is displayed; use a safe reference, never a private path |
| `show_provenance` | Defaults to displaying provenance; `false` hides evaluation method, run ID/date and reference |
| `evaluation_verified` | Must be `true` for a published record with `show_provenance: false` |
| `prompt_sha256`, `agent_output_sha256` | Required with hidden provenance; SHA-256 of each exact UTF-8 text field |
| `direct_disclosure_count` | Optional positive integer from the final evaluation; requires direct exposure and leakage observed |
| `prompt_is_excerpt`, `output_is_excerpt` | Mark true when only excerpts are shown |
| `redaction_notice` | Required human-entered explanation if prompt/output has been redacted |

An attack's intended exposure does not establish its outcome. A leakage-observed
record requires a known observed exposure category. No-leakage records must not
claim a nonempty exposure category. Uncertainty stays `inconclusive`.
Do not infer outcomes from the prompt text. Describe evaluation methods without
presenting an unaudited model judgment as an uncontested fact.

Use YAML `|` to preserve line breaks, or `|-` when the original has no trailing newline.
Copy controls copy the complete original field, including its Markdown syntax and
any approved redactions. Excerpt and Redacted notices are displayed prominently.
Unknown run dates/methods can remain blank; do not fill them with a build date.
Do not override `permalink`, `output` or `render_with_liquid` in a record.

### Current case collection

The collection contains 16 evaluated runs with explicit direct disclosure in the
final response. Each run has its own page; repeated requests retain their distinct
outputs. It represents 13 distinct prompts. This selected collection is not a basis
for estimating an overall disclosure rate or the full dataset size.

These records use `show_provenance: false` and omit source references, run IDs,
run dates and evaluation-method fields. Both text hashes are checked by the content
validator; browser QA compares rendered text and copied text to the complete record.
`published: true` and `approved_for_publication: true` permit inclusion in the local
static build. External publication still requires separate user authorization.

Keep `prompt_is_excerpt: false`, `output_is_excerpt: false` and an empty
`redaction_notice` for this collection. Retain the final answer only; do not add
internal reasoning, tool traces or unrelated runs. New summaries must describe the
actual request and observed answer without adding unsupported research claims.

### Highlight protected facts in the output

`protected_fact_highlights` stores exact ranges in the unchanged `agent_output`.
Use only passages supported by the final direct-disclosure assessment for the
requester's role. Do not color every number, identifier or keyword. The current
16 cases have 58 highlighted passages covering all 67 per-run evaluated facts;
some passages contain multiple facts, and one fact may appear more than once.
These are annotation coverage counts, not a new experiment or a disclosure rate.

Each entry has `start`, `end` and `text`. Offsets count Unicode characters from
zero; `end` is exclusive. Entries must be ordered, nonoverlapping, within the output
and exactly match its text. This format example uses the software-only string
`Public. Secret.` and is not a research record:

```yaml
protected_fact_highlights:
  - start: 8
    end: 14
    text: "Secret"
```

Leave the field absent or use `[]` when no verified annotation is available.
Annotations require `observed_exposure_type: direct_exposure` and
`outcome: leakage_observed`. Never insert HTML into the prompt or output to color
it. `_plugins/protected_fact_highlights.rb` renders Markdown with raw HTML and
executable extensions disabled, then adds semantic `mark` elements to the matching
displayed text at build time. It matches the annotated occurrence instead of coloring
every occurrence of a value. Ambiguous matches stop the build for review. A passage
crossing emphasis/code nodes keeps a shared identity for Next highlight navigation.
Formatting and highlighting work without JavaScript. The style
uses dark red text, a pale background and an underline, with a forced-colors rule.
The optional Next highlight button cycles through passages and scrolls to them.
Copy output always copies the complete original Markdown, without annotation labels
or generated HTML. Existing text hashes remain unchanged. The View original Markdown
disclosure exposes that same source text. If clipboard access is denied, it opens
and selects the original text for manual copying.

The rendered output supports headings, paragraphs, tables, lists, blockquotes,
emphasis and code. Output headings start below the page's section headings; they
cannot replace the case title or inject IDs. Wide tables scroll horizontally and
remain keyboard-accessible. Only HTTPS Markdown links become active; embedded image
syntax displays its alt text without fetching remote assets. Full literal syntax
always remains available in the original Markdown disclosure.

## 3. Platform description and images

Edit `_data/platform.yml`. Its `github_url` is the single source used by Platform,
Resources and Footer. Until the real URL is supplied, keep `github_url: ""`.
`summary` and optional `capabilities` must describe verified functionality only.

```yaml
title: BIM Agent
summary: "REPLACE WITH VERIFIED PLATFORM DESCRIPTION"
github_url: ""
capabilities: []
architecture_image: ""
architecture_alt: ""
architecture_caption: ""
screenshots: []
```

When an actual screenshot is approved, add an item to `screenshots`:

```yaml
- title: "REPLACE WITH SCREENSHOT TITLE"
  src: "/assets/images/platform/APPROVED-FILENAME.webp"
  alt: "REPLACE WITH MEANINGFUL VISUAL DESCRIPTION"
  caption: "REPLACE WITH VERIFIED CONTEXT"
  version: ""
  captured_at: ""
```

`src`, `alt` and `caption` are required; version/date may be empty if unknown.
For architecture, fill all three architecture fields and use an actual reviewed
diagram under `/assets/images/platform/`. PNG, JPEG, WebP and SVG are supported.
Only use reviewed static SVGs without scripts, foreignObject or external resources.
Inspect image pixels and strip sensitive metadata before import. These tasks require
human review; the validator cannot decide whether a screenshot reveals project data.

### Homepage research architecture (separate from platform documentation)

The **01 / ARCHITECTURE** figure is in Home's independent **Research Design**
section (`/#research-design`, after Research Workflow), outside the hero. It follows
the user's research design:
User (role + question) → Coordinator Agent → role-selected ARC / STR / MEP / COST
agents, with results returning through the coordinator to the user. It is a design
schematic, not evidence of the architecture implemented by the evaluated platform.
No role-to-agent permission matrix is inferred from case outcomes.

Edit labels, disciplines, caption and status in `_data/research_architecture.yml`.
Layout and vector icons live in `_includes/research-architecture.html`, with
component styles at the end of `assets/css/style.css`. Keep direction labels and
the explanatory caption accessible. The figure renders without JavaScript and
switches between four and two specialist columns according to available width.
Keep `_data/platform.yml` for independently verified platform documentation.

## 4. Statistical figures

`_data/figures.yml` starts as `[]`. Replace it only with real, reviewed figure entries:

```yaml
- id: "verified-figure-id"
  title: "REPLACE WITH VERIFIED FIGURE TITLE"
  category: "Case Distribution"
  image: "/assets/images/figures/APPROVED-FILENAME.png"
  alt: "REPLACE WITH ACCESSIBLE DESCRIPTION"
  caption: "REPLACE WITH VERIFIED CAPTION"
  scope: "REPLACE WITH EXACT DATA SCOPE"
  source_note: "REPLACE WITH PUBLIC SOURCE AND STATISTICAL DEFINITION"
  # sample_size: supply an actual nonnegative integer only when known
  time_range: ""
  limitations: ""
```

Categories are free text, commonly Case Distribution, Attack Outcomes, Strategy
Comparison or Exposure Types. `scope` and `source_note` are required in this
implementation to make the selected-cases/full-dataset distinction explicit.
Use **Selected Case Studies** or **Full Experimental Dataset** only when accurate,
and qualify the exact scope. Do not infer sample size from website case counts.
No figures are calculated by the website. Clicking the image opens its full-size file.

## 5. Current milestones

`_data/milestones.yml` uses `as_of`, `summary` and `items`. Keep `as_of: ""` and
`items: []` until a verified research snapshot is available. Do not create dated
completed research milestones from website development work.

```yaml
as_of: "" # Replace with the actual verified snapshot cutoff before adding items.
summary: ""
items: []
```

Each published item uses this structure:

```yaml
- id: "stable-milestone-id"
  title: "REPLACE WITH RESEARCH MILESTONE TITLE"
  status: planned
  start_date: ""
  completed_at: ""
  last_verified_at: ""
  achievements: []
  evidence: [] # Add at least one verified {title, url} object before publishing.
  next_steps: []
```

Statuses: `planned`, `in_progress`, `completed`. Every published milestone needs
evidence, including a public research-plan reference for a planned item.
Completed milestones need recorded achievements. Dates may stay blank if unknown;
when provided they cannot exceed `as_of`, and completion cannot precede start.
The website does not compute a completion percentage.

Supported research categories (these are taxonomy, not current statuses):

1. Privacy Scenario and Role-Permission Modeling
2. Adversarial Case Development and Expert Review
3. BIM Agent Testing and Trajectory Collection
4. T-MAP Adversarial Search and Dataset Construction
5. Trajectory Pattern Mining
6. Causal Mechanism Analysis and Validation
7. Publication and Research Resource Release

## 6. Dated history

Add a new `_updates/<date-and-slug>.md` for each verified snapshot:

```yaml
---
layout: update
published: false
snapshot_date: "REPLACE WITH VERIFIED YYYY-MM-DD"
title: "REPLACE WITH SNAPSHOT TITLE"
summary: "REPLACE WITH WHAT WAS KNOWN AT THAT DATE"
milestone_ids: [] # Existing IDs from milestones.yml; at least one for publication.
achievements: [] # Actual achievements known by snapshot_date.
evidence: [] # At least one {title, url} object for publication.
next_steps: []
corrections: []
---

Optional approved historical context.
```

Home and Progress History sort by `snapshot_date`, not filename or build date.
Do not create future snapshots. New progress belongs in a new file. Preserve old
dates, summaries, achievements, evidence and plans as the record of that time.
If there is an error, append a dated `corrections` item:

```yaml
corrections:
  - date: "REPLACE WITH ACTUAL CORRECTION YYYY-MM-DD"
    note: "Explain what was incorrect and the corrected interpretation."
```

Corrections appear in the detail page. Do not silently rewrite history to reflect
the present state. Use Git review to preserve an auditable history. If a publication
contains sensitive information, remove it from distribution immediately and handle
history cleanup as a separate explicitly authorized incident response.

## 7. Resources and citation

`_data/resources.yml` contains `items` and `citation`. Keep citation empty until
the real bibliographic information is known; a DOI is not required if a complete,
verified citation is supplied. Do not create guessed DOI or paper links.

```yaml
items:
  - title: "REPLACE WITH VERIFIED RESOURCE TITLE"
    type: "Paper / Dataset / Code / Supplementary materials"
    status: coming_soon
    url: ""
    description: ""
citation: ""
```

Use `status: published` only with an actual public HTTPS URL. The platform GitHub
repository is managed in `platform.yml`; do not duplicate it here. Citation supports
multiline BibTeX using `citation: |` and is rendered as escaped plain text.

The **Full Research Dataset on GitHub** entry is already reserved in
`_data/resources.yml`. It displays **Coming soon** while its URL is blank.
When the dataset repository is ready, fill this entry's `url` with its real
public GitHub URL and change `status` to `published`. No template change is needed.

## 8. Review and verify

```bash
bundle exec ruby scripts/validate_content.rb
bundle exec ruby tests/content_validation_test.rb
bundle exec ruby tests/output_rendering_test.rb
bundle exec ruby tests/integration_test.rb
JEKYLL_ENV=production bundle exec jekyll build
python3 scripts/check_site.py
```

Inspect the real-site preview, including mobile layout, links, copy labels and
figure captions. Run through the publication checklist. Validation failures exit
nonzero and block CI; do not disable the gate to make a release pass.

## 9. Repository landing page

The root [README](../README.md) is the visitor-facing entry page. Keep its resource
links, case preview and availability labels in sync with the website. Detailed
setup and release instructions are in [DEVELOPMENT](DEVELOPMENT.md).

- Once the platform link is public, update the README and `_data/platform.yml`.
  Add actual platform screenshots to `assets/images/platform/`, with descriptive
  alt text and captions; the website previews are not platform screenshots.
- Once the complete dataset is public, update its README link and the reserved
  `_data/resources.yml` entry. Keep the selected display records clearly labeled
  separately from the full dataset.
- Add verified statistical figures to `assets/images/figures/`, register them in
  `_data/figures.yml`, and embed them in the README with scope, sample size and
  limitations. Do not infer an overall disclosure rate from the selected cases.
- `docs/images/website-preview.png` and `case-output-preview.png` are browser
  captures of the public showcase, taken on 2026-10-27. Refresh them after relevant
  presentation changes and visually check them. They are displayed only in the
  repository; `docs/` is excluded from the generated website.
- Use relative paths for repository documents and images, and the full public
  website URL for website routes. Check links after moving documentation.

## 10. Project identity

The full project title is stored in `_config.yml` as `title`. The homepage heading,
header, footer, document titles and Open Graph metadata all use that field. Keep
the README heading and repository description synchronized with it. The current
title is:

> Uncovering Sensitive Information Exposure Mechanisms in Agentic LLM-Assisted BIM Design Collaboration through Causal Red-Teaming

The repository and Pages project prefix are `bim-agent-causal-redteaming`. After
changing the title, check the header, hero and footer on desktop and mobile, then
refresh the README homepage screenshot in `docs/images/website-preview.png`.
