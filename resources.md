---
title: Resources
permalink: /resources/
description: Platform source code, supporting materials and author contact for research data.
---
{% include page-heading.html eyebrow="05 / OPEN RESEARCH" %}
<div class="resource-list">
<article class="resource" id="dataset-access"><div><p class="eyebrow">DATASET ACCESS</p><h2>Full research dataset</h2><p>To request the full dataset, contact <a href="mailto:zhou-peng.wang@connect.polyu.hk?cc=xingyu.tao%40polyu.edu.hk">zhou-peng.wang@connect.polyu.hk</a> and CC xingyu.tao@polyu.edu.hk. Sharing is subject to data-owner permissions and review for confidentiality and inference risks.</p></div><span class="badge">Available on request</span></article>
<article class="resource"><div><p class="eyebrow">PLATFORM CODE</p><h2>ABCDE Platform GitHub Repository</h2></div>{% if site.data.platform.github_url and site.data.platform.github_url != '' %}<a class="button" href="{{ site.data.platform.github_url | escape }}" rel="noopener noreferrer">View on GitHub ↗</a>{% else %}<span class="badge">Coming soon</span>{% endif %}</article>
{% for resource in site.data.resources.items %}<article class="resource"><div><p class="eyebrow">{{ resource.type | escape }}</p><h2>{{ resource.title | escape }}</h2>{% if resource.description %}<p>{{ resource.description | escape }}</p>{% endif %}</div>{% if resource.status == 'published' %}<a class="button" href="{{ resource.url | escape }}" rel="noopener noreferrer">View resource ↗</a>{% else %}<span class="badge">Coming soon</span>{% endif %}</article>{% endfor %}
</div>
{% if site.data.resources.citation and site.data.resources.citation != '' %}<section class="section"><h2>Citation</h2><div class="text-panel"><button class="copy-button" type="button" data-copy="citation" hidden>Copy citation</button><pre id="citation">{{ site.data.resources.citation | escape }}</pre><span class="copy-status" aria-live="polite"></span></div></section>{% endif %}
