# BIM Agent Privacy Red-Teaming

Exploring role-based privacy boundaries and adversarial evaluation of BIM agents
in collaborative design.

**[Visit the website](https://zachary-wzp.github.io/bim-agent-privacy-website/)** ·
[Explore case studies](https://zachary-wzp.github.io/bim-agent-privacy-website/cases/) ·
[Research design](https://zachary-wzp.github.io/bim-agent-privacy-website/#research-design)

## Research resources

| Resource | Access | Currently available |
| --- | --- | --- |
| Research website | [Open website](https://zachary-wzp.github.io/bim-agent-privacy-website/) | Research overview, design schematic and 16 case studies |
| BIM Agent platform | **Coming soon** · [Platform information](https://zachary-wzp.github.io/bim-agent-privacy-website/platform/) | Platform link and screenshots awaiting publication |
| Full research dataset | **Coming soon** · [Published case records](_cases/) | Selected display records; the complete dataset will have a separate GitHub link |
| Statistical figures | **Coming soon** · [Statistics page](https://zachary-wzp.github.io/bim-agent-privacy-website/statistics/) | Figures awaiting verified results and captions |

## Website preview

[![Research website homepage with navigation, introduction and links to the case studies](docs/images/website-preview.png)](https://zachary-wzp.github.io/bim-agent-privacy-website/)

The website includes six sections: Home, BIM Agent, Case Studies, Statistics,
Research Progress and Resources. Case outputs render Markdown tables and lists,
highlight protected facts and preserve the complete original text when copied.

## BIM Agent platform

**Platform link and screenshots: coming soon.**

This section will include the public platform link, screenshots and descriptions
of verified capabilities. The preview above shows the research website.
[Platform information](https://zachary-wzp.github.io/bim-agent-privacy-website/platform/)
will be updated when these materials are available.

## Dataset and case preview

**Full dataset on GitHub: coming soon.** The published collection currently contains
16 runs across 13 distinct prompts. These cases were selected because their final
responses explicitly disclosed protected facts. This selection does not establish
an overall disclosure rate or represent the complete evaluation dataset.

| Case | Requester role | Final response preview |
| --- | --- | --- |
| [S01-001 · Plumbing design notes](https://zachary-wzp.github.io/bim-agent-privacy-website/cases/s01-001/) | Architect | Plumbing design-review notes and a proposed route revision |
| [S02-001 · Commercial terms](https://zachary-wzp.github.io/bim-agent-privacy-website/cases/s02-001/) | BIM Coordinator | Commercial ledger entries in a ceiling quantity reconciliation |
| [S06-004 · Foundation design details](https://zachary-wzp.github.io/bim-agent-privacy-website/cases/s06-004/) | Cost Consultant | Internal foundation design details in an urgent cost review |

[![S01-001 final output rendered on the case page, with the protected design note and route revision highlighted](docs/images/case-output-preview.png)](https://zachary-wzp.github.io/bim-agent-privacy-website/cases/s01-001/)

*S01-001 output as displayed on the website. Highlighted passages identify
protected facts; one passage may contain multiple facts.*

[Browse all 16 case studies](https://zachary-wzp.github.io/bim-agent-privacy-website/cases/)
or [inspect the published Markdown/YAML records](_cases/). Each record includes
the full prompt, final output, requester role, evaluation outcome and reviewed
highlight ranges. The website supports copying the complete original output and
switching directly between cases.

## Statistical figures

**Coming soon.** No verified statistical figures have been published yet.
Future figures will appear here with captions, evaluation scope, sample sizes and
limitations, and on the [Statistics page](https://zachary-wzp.github.io/bim-agent-privacy-website/statistics/).

## Development and maintenance

The website is built with Jekyll, Markdown/YAML and native HTML, CSS and JavaScript.
This repository contains the showcase website and its published case selection.

- [Local preview, validation and deployment](docs/DEVELOPMENT.md)
- [Content maintenance guide](docs/CONTENT_GUIDE.md)
- [Verification record](docs/VERIFICATION.md)
- [Publication checklist](docs/PUBLICATION_CHECKLIST.md)

Materials still to add: the public Agent platform link and screenshots, the full
dataset URL and documentation, verified statistical figures, research progress
records and publication/citation details.
