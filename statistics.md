---
title: Statistics
permalink: /statistics/
description: Preliminary evidence for Task 2 of the research framework.
---
{% include page-heading.html eyebrow="03 / RESEARCH RESULTS" %}
{% assign groups = site.data.figures | group_by: 'category' %}
{% for group in groups %}
<section class="section">
  <h2>{{ group.name | escape }}</h2>
  {% if group.name == 'Initial Results' %}
  <div class="prose">
    <p>The Task 2 pilot generated <strong>3,963 BIM-specific prompts</strong> across four projects and eight collaboration scenarios. It covered seven test strategies and two intended exposure types, direct and inference-based.</p>
    <p>Figure 4b–d of the proposal asks three questions. How often did tests produce exposure? How evenly were prompts distributed across cells? How similar were the tasks within each scenario?</p>
    <p class="notice">The <a href="{{ '/cases/' | relative_url }}">public case collection</a> illustrates individual runs selected for direct disclosure. The exposure rate below gives each scenario equal weight. The pilot total alone cannot recover the number of exposed runs.</p>
  </div>
  {% endif %}
  <div class="figure-group">{% for figure in group.items %}{% include figure-card.html figure=figure %}{% endfor %}</div>
</section>
{% else %}
<section class="section">{% include empty.html title="Verified statistics will be added as results become available" text="Only reviewed figures from actual research results will be published, with captions, data scope and any known limitations." %}</section>
{% endfor %}
