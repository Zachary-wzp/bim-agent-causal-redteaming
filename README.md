# Uncovering Sensitive Information Exposure Mechanisms in Agentic LLM-Assisted BIM Design Collaboration through Causal Red-Teaming

What can a collaborator learn from an agent that they are not authorized to learn from the building model? This project studies direct disclosures, facts that can be inferred across replies, and the interactions that might explain either outcome.

**[Visit the website](https://zachary-wzp.github.io/bim-agent-causal-redteaming/)** ·
[Three research tasks](https://zachary-wzp.github.io/bim-agent-causal-redteaming/#research-framework) ·
[Preliminary results](https://zachary-wzp.github.io/bim-agent-causal-redteaming/statistics/) ·
[Evaluation design and milestones](https://zachary-wzp.github.io/bim-agent-causal-redteaming/progress/#evaluation)

## Research resources

| Resource | Access | Currently available |
| --- | --- | --- |
| Research website | [Open website](https://zachary-wzp.github.io/bim-agent-causal-redteaming/) | Research overview, design schematic and 16 case studies |
| ABCDE Platform | [Source code](https://github.com/yixinhenry/agentic-bim-common-data-environment-platform) · [Platform showcase](https://zachary-wzp.github.io/bim-agent-causal-redteaming/platform/) | Overview, demonstration video and three screenshots |
| Full research dataset | [Contact the authors](https://zachary-wzp.github.io/bim-agent-causal-redteaming/resources/#dataset-access) | Available on request; [representative case records](_cases/) are public |
| Initial results | [Statistics page](https://zachary-wzp.github.io/bim-agent-causal-redteaming/statistics/) | Three figures: task similarity, exposure rates and cell coverage |

## Website preview

[![Research homepage with the IFC building from the ABCDE workspace and links to cases and initial results](docs/images/website-preview.png)](https://zachary-wzp.github.io/bim-agent-causal-redteaming/)

The website includes six sections: Home, BIM Agent, Case Studies, Statistics,
Research Progress and Resources. Case outputs render Markdown tables and lists,
highlight protected facts and preserve the complete original text when copied.

## ABCDE Platform

[ABCDE (Agentic BIM Common Data Environment Platform)](https://github.com/yixinhenry/agentic-bim-common-data-environment-platform)
supports natural-language BIM queries, IFC editing, federated model viewing,
clash candidate detection, CAD-to-IFC generation and initial model creation.

[![ABCDE workspace with an IFC model, role navigation and agent conversation](assets/images/platform/abcde-overview.png)](https://zachary-wzp.github.io/bim-agent-causal-redteaming/platform/)

[Explore the platform showcase](https://zachary-wzp.github.io/bim-agent-causal-redteaming/platform/)
for the embedded demonstration and all three screenshots, or
[watch the video on YouTube](https://youtu.be/StFWHwiCAeQ).

## Dataset and case preview

**Full dataset: available on request from the authors.** Please contact
[zhou-peng.wang@connect.polyu.hk](mailto:zhou-peng.wang@connect.polyu.hk?cc=xingyu.tao%40polyu.edu.hk)
and CC xingyu.tao@polyu.edu.hk. The published collection currently contains
16 runs across 13 distinct prompts. These cases were selected because their final
responses explicitly disclosed protected facts. This selection does not establish
an overall disclosure rate or represent the complete evaluation dataset.

| Case | Requester role | Final response preview |
| --- | --- | --- |
| [S01-001 · Plumbing design notes](https://zachary-wzp.github.io/bim-agent-causal-redteaming/cases/s01-001/) | Architect | Plumbing design-review notes and a proposed route revision |
| [S02-001 · Commercial terms](https://zachary-wzp.github.io/bim-agent-causal-redteaming/cases/s02-001/) | BIM Coordinator | Commercial ledger entries in a ceiling quantity reconciliation |
| [S06-004 · Foundation design details](https://zachary-wzp.github.io/bim-agent-causal-redteaming/cases/s06-004/) | Cost Consultant | Internal foundation design details in an urgent cost review |

[![S01-001 final output rendered on the case page, with the protected design note and route revision highlighted](docs/images/case-output-preview.png)](https://zachary-wzp.github.io/bim-agent-causal-redteaming/cases/s01-001/)

*S01-001 output as displayed on the website. Highlighted passages identify
protected facts; one passage may contain multiple facts.*

[Browse all 16 case studies](https://zachary-wzp.github.io/bim-agent-causal-redteaming/cases/)
or [inspect the published Markdown/YAML records](_cases/). Each record includes
the full prompt, final output, requester role, evaluation outcome and reviewed
highlight ranges. The website supports copying the complete original output and
switching directly between cases.

## Project progress

[View the research milestones](https://zachary-wzp.github.io/bim-agent-causal-redteaming/progress/).
As of 2026-11-17, Task 1 Steps 1–2 and Task 2 Steps 1–2 are confirmed complete.
The nine steps are grouped under the SFC graph-based method, D² matrix-guided
evolutionary model, and causal exposure-mechanism analysis. Completion of the
other five steps has not been confirmed.

## Initial results

The Task 2 pilot generated 3,963 prompts across four BIM projects and eight
collaboration scenarios, covering seven test strategies and two intended exposure
types. Proposal Figure 4b compares exposure rates, Figure 4c shows prompt
allocation across cells, and Figure 4d reports task similarity. The 16 public cases
illustrate individual runs selected for direct disclosure. Validation of causal
mechanisms is a subsequent research task.

### Task similarity

Mean task similarity is below the 0.85 threshold in each of the eight scenarios.
The threshold comparison refers to scenario means; individual cases can exceed it.

[![Task similarity across eight scenarios, with each mean below the 0.85 threshold](assets/images/figures/task-similarity.png)](assets/images/figures/task-similarity.pdf)

[View PDF](assets/images/figures/task-similarity.pdf)

### Exposure rates

The proposed method outperforms all five baselines in macro-average exposure rate,
reaching **63.8% across eight scenarios**. This comparison concerns the macro-average;
the proposed method does not have the highest rate in every scenario. Case counts
and uncertainty estimates are not specified in this figure.

[![Exposure rates across eight scenarios and their macro-average for six methods](assets/images/figures/exposure-comparison.png)](assets/images/figures/exposure-comparison.pdf)

[View PDF](assets/images/figures/exposure-comparison.pdf)

### Cell coverage

The proposed method achieves more uniform cell coverage. The figure shows estimated
prompts per cell for **168 cells per method**, with reference lines for the scaled
quota of 20 and uniform allocation of 23.59.

[![Estimated prompts per cell for six methods, showing a tighter distribution for the proposed method](assets/images/figures/cell-coverage.png)](assets/images/figures/cell-coverage.pdf)

[View PDF](assets/images/figures/cell-coverage.pdf) ·
[View all initial results](https://zachary-wzp.github.io/bim-agent-causal-redteaming/statistics/)

## Development and maintenance

The website is built with Jekyll, Markdown/YAML and native HTML, CSS and JavaScript.
This repository contains the showcase website and its published case selection.

- [Local preview, validation and deployment](docs/DEVELOPMENT.md)
- [Content maintenance guide](docs/CONTENT_GUIDE.md)
- [Verification record](docs/VERIFICATION.md)
- [Publication checklist](docs/PUBLICATION_CHECKLIST.md)

Materials still to add: the evaluated-platform architecture diagram, dataset
documentation, supporting experimental details, subsequent research progress
updates and publication/citation details.
