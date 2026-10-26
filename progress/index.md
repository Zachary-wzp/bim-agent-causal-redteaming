---
title: Project Progress
permalink: /progress/
description: Research milestones and dated snapshots, grounded in recorded evidence.
---
{% include page-heading.html eyebrow="04 / RESEARCH LOG" %}
{% assign milestones = site.data.milestones %}
{% assign updates = site.updates | where: 'published', true | sort: 'snapshot_date' | reverse %}
{% assign public_cases = site.cases | where: 'published', true | where: 'approved_for_publication', true %}
<p class="notice">This page records research progress. Website development is not included. Dates refer to verified research snapshots.</p>
<section class="section"><h2>Current Progress Snapshot</h2>{% if milestones.as_of and milestones.as_of != '' %}<p class="eyebrow">As of <time datetime="{{ milestones.as_of }}">{{ milestones.as_of }}</time></p>{% if milestones.summary != '' %}<p>{{ milestones.summary | escape }}</p>{% endif %}<p>{{ public_cases.size }} <strong>Published Cases</strong> currently available on this website.</p>{% elsif updates.size > 0 %}{% assign latest = updates.first %}<article class="update-preview"><time datetime="{{ latest.snapshot_date }}">As of {{ latest.snapshot_date }}</time><h3><a href="{{ latest.url | relative_url }}">{{ latest.title | escape }}</a></h3><p>{{ latest.summary | escape }}</p></article>{% else %}{% include empty.html title="Research progress has not yet been published" text="A current snapshot will appear when its date, achievements and supporting evidence have been verified." %}{% endif %}</section>
<section class="section"><h2>Milestone Timeline</h2>{% if milestones.items.size > 0 %}<ol class="timeline">{% for milestone in milestones.items %}{% include milestone.html milestone=milestone %}{% endfor %}</ol>{% else %}{% include empty.html title="Verified milestones are coming soon" text="Milestone statuses, recorded dates, achievements and next steps will be added from approved research records." %}{% endif %}</section>
<section class="section"><h2>Progress History</h2><p class="small">Each update preserves what was known as of its snapshot date. Later corrections are identified explicitly.</p>{% if updates.size > 0 %}<ol class="history">{% for update in updates %}<li><time datetime="{{ update.snapshot_date }}">As of {{ update.snapshot_date }}</time><h3><a href="{{ update.url | relative_url }}">{{ update.title | escape }}</a></h3><p>{{ update.summary | escape }}</p></li>{% endfor %}</ol>{% else %}{% include empty.html title="Progress updates will be published here" text="No verified research snapshots have been published yet." %}{% endif %}</section>
