---
title: Statistics
permalink: /statistics/
description: Initial results on generated case similarity, exposure rates and cell coverage.
---
{% include page-heading.html eyebrow="03 / RESEARCH RESULTS" %}
<p class="notice"><strong>Initial results.</strong> These figures describe the experiments specified in each caption. They are separate from the representative cases displayed on this website; the displayed case count is not the experimental sample size.</p>
{% if site.data.figures.size > 0 %}{% assign groups = site.data.figures | group_by: 'category' %}{% for group in groups %}<section class="section"><h2>{{ group.name | escape }}</h2><div class="figure-group">{% for figure in group.items %}{% include figure-card.html figure=figure %}{% endfor %}</div></section>{% endfor %}{% else %}<section class="section">{% include empty.html title="Verified statistics will be added as results become available" text="Only reviewed figures from actual research results will be published, with captions, data scope and any known limitations." %}</section>{% endif %}
