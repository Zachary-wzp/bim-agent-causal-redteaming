---
title: Case Studies
permalink: /cases/
description: Explore reviewed adversarial requests, recorded agent responses and evidence-based outcomes.
case_explorer: true
---
{% include page-heading.html eyebrow="02 / CASE EXPLORER" %}
{% assign public_cases = site.cases | where: 'published', true | where: 'approved_for_publication', true | sort: 'case_id' %}
<p class="notice">Only representative cases are shown here. Due to the potentially harmful nature of these cases, please contact <a href="mailto:zhou-peng.wang@connect.polyu.hk?cc=xingyu.tao%40polyu.edu.hk">zhou-peng.wang@connect.polyu.hk</a> and CC xingyu.tao@polyu.edu.hk to request the full case collection.</p>
<p class="notice"><strong>Reading a case.</strong> Start with the requester's role, then compare the intended exposure with the highlighted passage in the final reply. Each published run was selected because it directly disclosed a protected fact. A repeated request can yield a different reply. See the <a href="{{ '/statistics/' | relative_url }}">pilot comparison</a> for rates and the <a href="{{ '/progress/' | relative_url }}#detector-evaluation">detector evaluation design</a> for inference across several replies.</p>
<div data-case-explorer>
  <form class="filters" data-filters hidden role="search" aria-label="Filter case studies">
    <div class="filter-grid">
      <label for="case-search">Search Case ID or title<input id="case-search" type="search" name="search" placeholder="Search cases…" autocomplete="off"></label>
      <label for="scenario-filter">Scenario<select id="scenario-filter" name="scenario_id"><option value="">All scenarios</option></select></label>
      <label for="role-filter">Requester Role<select id="role-filter" name="requester_role"><option value="">All roles</option></select></label>
      <label for="strategy-filter">Attack Strategy<select id="strategy-filter" name="attack_strategy"><option value="">All strategies</option></select></label>
      <label for="exposure-filter">Intended Exposure Type<select id="exposure-filter" name="intended_exposure_type"><option value="">All intended types</option></select></label>
      <label for="outcome-filter">Observed Outcome<select id="outcome-filter" name="outcome"><option value="">All outcomes</option></select></label>
    </div>
    <div class="filter-actions"><p data-result-count role="status" aria-live="polite">{{ public_cases.size }} Published Cases</p><button class="button secondary" type="reset">Reset Filters</button></div>
  </form>
  <noscript><p class="notice">All {{ public_cases.size }} published cases are listed below. Enable JavaScript to use search and filters.</p></noscript>
  {% if public_cases.size > 0 %}<div class="case-grid">{% for case in public_cases %}{% include case-card.html case=case %}{% endfor %}</div>{% else %}{% include empty.html title="Reviewed case studies are coming soon" text="No publicly approved cases are available yet. Verified prompts, agent outputs and evaluation outcomes will appear here after review." %}{% endif %}
  <div data-no-results hidden>{% include empty.html title="No cases match these filters" text="Try another search or use Reset Filters to show all published cases." %}</div>
</div>
