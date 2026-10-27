# Publication checklist

Current repository (renamed on 2026-10-27):
[Zachary-wzp/bim-agent-causal-redteaming](https://github.com/Zachary-wzp/bim-agent-causal-redteaming).

用户于 2026-10-26 指定 Zachary-wzp/bim-agent-privacy-website 并授权发布当前网站。
范围包括六个页面、现有 16 个案例和研究设计示意图。案例保留完整原文、不脱敏、
不展示来源；用户确认其中的敏感值非真实数据。新增材料仍需审核。

以下清单保留为后续版本的审核模板；首次发布结果见 GitHub Actions 和验证报告。
缺失的平台材料、统计图和进度记录继续使用空状态；研究设计图独立标注为设计示意。

## Research and permission

- [ ] BIM Agent repository URL is authentic and its visibility is approved.
- [ ] Capabilities and architecture correspond to the actual evaluated platform.
- [ ] Each case maps to a real test run and a verified evaluation record.
- [ ] Each published case has both publication flags explicitly set to true.
- [ ] Intended and observed exposure are distinguished; uncertainty is not overstated.
- [ ] Prompt/output text is faithful to the approved source and marked Excerpt / Redacted when appropriate.
- [ ] The agreed provenance-display setting is respected; the current 16 cases display no source metadata.
- [ ] Cases without displayed provenance have verified evaluations and matching prompt/output hashes.
- [ ] Statistical figures agree with experiment records, with correct scope and definitions.
- [ ] Sample sizes and success rates have not been inferred from selected public cases.
- [ ] Research milestone statuses, dates and evidence are verified.
- [ ] Historical snapshots preserve what was known then; corrections are explicitly dated.
- [ ] Resource URLs, citation information and any DOI are real and verified.

## Public safety review

- [ ] No restricted IFC models, raw trajectories, cost tables, contracts or third-party private materials are included.
- [ ] No real restricted identifiers, credentials, internal URLs or private paths appear; the approved synthetic case values remain intact.
- [ ] Screenshot pixels have been checked and any restricted values redacted.
- [ ] Image metadata has been inspected and sensitive metadata removed.
- [ ] SVGs contain no executable scripts, external references or embedded active content.
- [ ] Unpublished records are also safe for the source repository; private content is stored elsewhere.
- [ ] Staged files and repository history have been reviewed for accidental disclosure.
- [ ] Generated `_site`, dependencies, `.qa`, local configuration and secrets are ignored.

## Technical verification

- [ ] Content validation and regression checks pass.
- [ ] Production Jekyll build passes without disabling content gates.
- [ ] All six routes and any case/update detail routes work with the actual baseurl.
- [ ] Images, full-size links and evidence anchors work.
- [ ] 360 / 768 / 1440 px layouts have been reviewed.
- [ ] Keyboard focus, menu, filters, copy controls and no-JavaScript navigation work.
- [ ] Empty states are accurate; no software fixture appears in public output.
- [ ] `_config.yml` uses the real origin and repository path for release.

## Explicit release authorization

- [ ] The researcher has explicitly approved the repository and website for public release.
- [ ] GitHub Pages visibility has been checked independently of repository visibility.
- [ ] Pages uses GitHub Actions, and environment protection rules are appropriate.
- [ ] `PAGES_DEPLOYMENT_APPROVED=true` is enabled only after the above approval.
- [ ] The authorized reviewer has checked the exact build to be released.

This reusable checklist is not a claim that missing research materials exist.
The current release authorization is recorded above; local previews and passing
tests do not grant authorization for additional material outside that scope.
