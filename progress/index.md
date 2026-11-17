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
{% if updates.size > 0 %}<section class="section"><h2>Progress History</h2><p class="small">Each update preserves what was known as of its recorded date. Later corrections are identified explicitly.</p><ol class="history">{% for update in updates %}<li><time datetime="{{ update.snapshot_date }}">As of {{ update.snapshot_date }}</time><h3><a href="{{ update.url | relative_url }}">{{ update.title | escape }}</a></h3><p>{{ update.summary | escape }}</p></li>{% endfor %}</ol></section>{% endif %}
