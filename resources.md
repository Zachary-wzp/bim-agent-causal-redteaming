---
title: Resources
permalink: /resources/
description: Public code, papers, datasets and supporting research materials.
---
{% include page-heading.html eyebrow="05 / OPEN RESEARCH" %}
<div class="resource-list">
<article class="resource"><div><p class="eyebrow">PLATFORM CODE</p><h2>BIM Agent GitHub Repository</h2></div>{% if site.data.platform.github_url and site.data.platform.github_url != '' %}<a class="button" href="{{ site.data.platform.github_url | escape }}" rel="noopener noreferrer">View on GitHub ↗</a>{% else %}<span class="badge">Coming soon</span>{% endif %}</article>
{% for resource in site.data.resources.items %}<article class="resource"><div><p class="eyebrow">{{ resource.type | escape }}</p><h2>{{ resource.title | escape }}</h2>{% if resource.description %}<p>{{ resource.description | escape }}</p>{% endif %}</div>{% if resource.status == 'published' %}<a class="button" href="{{ resource.url | escape }}" rel="noopener noreferrer">View resource ↗</a>{% else %}<span class="badge">Coming soon</span>{% endif %}</article>{% endfor %}
</div>
{% if site.data.resources.items.size == 0 %}<section class="section">{% include empty.html title="Research resources are coming soon" text="Links to project repositories, papers, datasets and supplementary materials will be added when they are publicly available." %}</section>{% endif %}
{% if site.data.resources.citation and site.data.resources.citation != '' %}<section class="section"><h2>Citation</h2><div class="text-panel"><button class="copy-button" type="button" data-copy="citation" hidden>Copy citation</button><pre id="citation">{{ site.data.resources.citation | escape }}</pre><span class="copy-status" aria-live="polite"></span></div></section>{% endif %}
