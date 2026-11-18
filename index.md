---
title: Home
description: Investigating sensitive information exposure mechanisms in agentic LLM-assisted BIM design collaboration through causal red-teaming.
---
{% assign public_cases = site.cases | where: 'published', true | where: 'approved_for_publication', true %}
{% assign updates = site.updates | where: 'published', true | sort: 'snapshot_date' | reverse %}
{% assign exposure_comparison = site.data.figures | where: 'id', 'exposure-comparison' | first %}
<section class="hero">
  <div class="hero-copy">
    <p class="eyebrow">BIM research / Causal red-teaming</p>
    <h1>{{ site.title | escape }}</h1>
    <p class="hero-description">When BIM agents work across disciplines, what can a collaborator learn beyond their permissions? We study what a response reveals on its own, what several replies reveal together, and how to test which interactions caused the exposure.</p>
    <div class="actions">
      <a class="button" href="{{ '/statistics/' | relative_url }}">View preliminary results <span aria-hidden="true">↗</span></a>
      <a class="text-link" href="#research-framework">Explore the three research tasks <span aria-hidden="true">↓</span></a>
    </div>
  </div>
  <figure class="model-sheet">
    <div class="model-sheet-title"><span>Architectural model</span><span>IFC</span></div>
    <div class="model-frame">
      <img src="{{ '/assets/images/platform/abcde-overview.png' | relative_url }}" alt="Stepped multi-storey IFC building in the ABCDE model viewer" width="1747" height="900" fetchpriority="high">
      <div class="model-datums" aria-hidden="true"><span>Roof</span><span>Base</span></div>
    </div>
    <figcaption><a href="{{ '/platform/' | relative_url }}">Explore the ABCDE workspace <span aria-hidden="true">↗</span></a></figcaption>
  </figure>
</section>
<div class="research-strip"><a href="{{ '/cases/' | relative_url }}"><strong>{{ public_cases.size }}</strong> Published Cases <span aria-hidden="true">↗</span></a><a href="#research-design">Research design <span aria-hidden="true">↓</span></a><a href="{{ '/progress/' | relative_url }}">Project progress <span aria-hidden="true">↗</span></a></div>
<section class="section overview">
  <div><p class="eyebrow">The research question</p><h2>What does a conversation reveal?</h2></div>
  <div class="overview-copy">
    <p>A project team may share a building model while keeping design decisions or commercial terms available only to certain roles. A reply can disclose a protected fact directly. Several replies can also supply enough spatial or engineering context to infer a fact that no single reply states.</p>
    <p>A BIM manager deciding whether to deploy an agent needs to know where an authorization check would help. That requires tracing a disclosure across the conversation and testing whether a safeguard reduces exposure while the team can still do its work.</p>
  </div>
</section>
<section class="section" id="research-framework" aria-labelledby="framework-title">
  <div class="section-heading"><div><p class="eyebrow">Research framework</p><h2 id="framework-title">Detect, elicit and explain exposure</h2></div></div>
  <ol class="workflow">
    <li><span>01</span><h3>Detect</h3><p>Can a reader infer a protected fact from several replies? The Sensitive-Fact-Centric (SFC) graph connects evidence across turns using BIM relationships. A separate inference step sees the evidence and domain knowledge while the protected answer is withheld.</p><a href="{{ '/progress/' | relative_url }}#detector-evaluation">How detection will be evaluated</a></li>
    <li><span>02</span><h3>Elicit</h3><p>Do the tests cover different ways information can be exposed? The Dual-Diversity (D²) matrix groups prompts by strategy and exposure type.{% if exposure_comparison %} {{ exposure_comparison.caption | escape }}{% endif %}</p><a href="{{ '/statistics/' | relative_url }}">Inspect the pilot results</a></li>
    <li><span>03</span><h3>Explain</h3><p>Which agent interactions actually contribute to exposure? The study will compare runs with and without exposure, identify candidate pathways, then test them through controlled interventions across projects and language models.</p><a href="{{ '/progress/' | relative_url }}#causal-evaluation">How a pathway will be tested</a></li>
  </ol>
</section>
<section class="section research-design" id="research-design" aria-labelledby="research-design-title">
  <div class="research-design-copy"><p class="eyebrow">RESEARCH DESIGN</p><h2 id="research-design-title">Role-aware specialist collaboration</h2><p>The research design places a coordinator between the user and four specialist agents for architecture, structure, building services and cost.</p><p>The coordinator selects the relevant agents according to the user's role, delegates the question and combines their responses into an answer.</p><p class="small">Design schematic. The case studies separately document observed outputs from evaluated runs.</p><a class="text-link" href="{{ '/platform/' | relative_url }}">ABCDE Platform →</a></div>
  {% include research-architecture.html %}
</section>
<section class="section"><div class="section-heading"><div><p class="eyebrow">EXPLORE THE PROJECT</p><h2>A closer look at the research</h2></div></div><div class="explore-grid">
  <a class="explore-item" href="{{ '/platform/' | relative_url }}"><span class="index">01 / PLATFORM</span><h3>ABCDE Platform <span>↗</span></h3><p>Platform overview, demonstration video and workspace screenshots.</p></a>
  <a class="explore-item" href="{{ '/cases/' | relative_url }}"><span class="index">02 / EVIDENCE</span><h3>Case Studies <span>↗</span></h3><p>Reviewed prompts, recorded outputs and evaluation outcomes.</p></a>
  <a class="explore-item" href="{{ '/statistics/' | relative_url }}"><span class="index">03 / RESULTS</span><h3>Statistics <span>↗</span></h3><p>Initial results on task similarity, exposure rates and cell coverage.</p></a>
  <a class="explore-item" href="{{ '/progress/' | relative_url }}"><span class="index">04 / RESEARCH LOG</span><h3>Project Progress <span>↗</span></h3><p>Three research tasks, nine steps and their current status.</p></a>
</div></section>
<section class="section"><div class="section-heading"><h2>Latest Progress</h2><a class="text-link" href="{{ '/progress/' | relative_url }}">View milestones →</a></div>{% if updates.size > 0 %}{% assign latest = updates.first %}<article class="update-preview"><time datetime="{{ latest.snapshot_date }}">As of {{ latest.snapshot_date }}</time><h3><a href="{{ latest.url | relative_url }}">{{ latest.title | escape }}</a></h3><p>{{ latest.summary | escape }}</p></article>{% elsif site.data.milestones.as_of and site.data.milestones.as_of != '' %}<article class="update-preview"><time datetime="{{ site.data.milestones.as_of }}">As of {{ site.data.milestones.as_of }}</time><p>{{ site.data.milestones.summary | escape }}</p></article>{% else %}{% include empty.html title="Research progress will be published here" text="Confirmed milestones will appear as research advances." %}{% endif %}</section>
<section class="section"><div class="section-heading"><h2>Featured Cases</h2><a class="text-link" href="{{ '/cases/' | relative_url }}">All case studies →</a></div>{% if public_cases.size > 0 %}<div class="case-grid">{% for case in public_cases limit:3 %}{% include case-card.html case=case %}{% endfor %}</div>{% else %}{% include empty.html title="Reviewed case studies are coming soon" text="Only verified test runs approved for public release will appear here. No case studies have been published yet." %}{% endif %}</section>
