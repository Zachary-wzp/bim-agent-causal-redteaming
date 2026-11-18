---
title: Project Progress
permalink: /progress/
description: Research milestones organized by the three tasks in the research plan.
---
{% include page-heading.html eyebrow="04 / RESEARCH LOG" %}
{% assign milestones = site.data.milestones %}
{% assign updates = site.updates | where: 'published', true | sort: 'snapshot_date' | reverse %}
{% assign public_cases = site.cases | where: 'published', true | where: 'approved_for_publication', true %}
<p class="notice">Completion status reflects the project author's confirmation. Only steps confirmed complete carry a Completed marker.</p>
<section class="section"><h2>Current Status</h2>{% if milestones.as_of and milestones.as_of != '' %}<p class="eyebrow">As of <time datetime="{{ milestones.as_of }}">{{ milestones.as_of }}</time></p>{% if milestones.summary != '' %}<p>{{ milestones.summary | escape }}</p>{% endif %}<p>{{ public_cases.size }} <strong>Published Cases</strong> currently available on this website.</p>{% endif %}</section>
<section class="section"><h2>Milestone Timeline</h2>
{% assign task_groups = milestones.items | group_by: 'task' %}
{% for task in task_groups %}
{% if task.name and task.name != '' %}<h3 class="milestone-task">{{ task.name | escape }}</h3>{% endif %}
<ol class="timeline">{% for milestone in task.items %}{% include milestone.html milestone=milestone %}{% endfor %}</ol>
{% endfor %}
</section>
<section class="section prose" id="evaluation" aria-labelledby="evaluation-title">
  <div class="section-heading"><div><p class="eyebrow">Evaluation design</p><h2 id="evaluation-title">What evidence would support each claim?</h2></div></div>
  <h3 id="detector-evaluation">Task 1 · Can the detector distinguish sufficient from insufficient evidence?</h3>
  <p>The proposal calls for BIM experts to annotate at least 500 multi-turn conversations across at least 15 scenarios. The test set will include exchanges that mention relevant details yet leave the protected fact unresolved. Evidence F1 and relation macro-F1 will assess the graph. Exposure F1 will measure agreement with expert judgments about what can be inferred.</p>
  <h3 id="pilot-evaluation">Task 2 · Do the test prompts cover realistic BIM work?</h3>
  <p>The <a href="{{ '/statistics/' | relative_url }}">pilot figures</a> report exposure rate, prompt allocation and similarity. The full evaluation will also check whether each prompt fits its assigned cell and ask BIM practitioners to judge its realism. Comparisons will use common starting prompts across methods.</p>
  <h3 id="causal-evaluation">Task 3 · Would changing one interaction change the outcome?</h3>
  <p>The study aims to collect about 50,000 interaction histories from roughly 10,000 prompts, each run at least five times. Runs with and without exposure will both contribute. Only interactions preceding the outcome will enter the analysis of candidate pathways.</p>
  <p>Paired tests will vary one prompt feature while holding the BIM context fixed. A second test will interrupt the suspected interaction and check whether exposure falls while ordinary design tasks still succeed. The proposal calls for testing across at least five independent BIM projects and four language models. Causal validation remains open.</p>
</section>
{% if updates.size > 0 %}<section class="section"><h2>Progress History</h2><p class="small">Each update preserves what was known as of its recorded date. Later corrections are identified explicitly.</p><ol class="history">{% for update in updates %}<li><time datetime="{{ update.snapshot_date }}">As of {{ update.snapshot_date }}</time><h3><a href="{{ update.url | relative_url }}">{{ update.title | escape }}</a></h3><p>{{ update.summary | escape }}</p></li>{% endfor %}</ol></section>{% endif %}
