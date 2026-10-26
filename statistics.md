---
title: Statistics
permalink: /statistics/
description: Verified experimental figures, with context for what was measured and how.
---
{% include page-heading.html eyebrow="03 / RESEARCH RESULTS" %}
<p class="notice"><strong>Scope matters.</strong> Selected Case Studies describe the public case selection. Full Experimental Dataset figures describe a separately documented experiment scope. Published case counts must not be treated as full-dataset sample sizes.</p>
{% if site.data.figures.size > 0 %}{% assign groups = site.data.figures | group_by: 'category' %}{% for group in groups %}<section class="section"><h2>{{ group.name | escape }}</h2><div class="figure-group">{% for figure in group.items %}{% include figure-card.html figure=figure %}{% endfor %}</div></section>{% endfor %}{% else %}<section class="section">{% include empty.html title="Verified statistics will be added as results become available" text="Only reviewed figures from actual research results will be published, with captions, data scope and any known limitations." %}</section>{% endif %}
