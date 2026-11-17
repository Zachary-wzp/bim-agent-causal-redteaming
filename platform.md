---
title: ABCDE Platform
permalink: /platform/
description: Agentic BIM Common Data Environment Platform
---
{% assign platform = site.data.platform %}
{% include page-heading.html eyebrow="01 / THE PLATFORM" %}

<section class="section prose" aria-labelledby="platform-overview-title">
  <h2 id="platform-overview-title">Platform overview</h2>
  <p>{{ platform.summary | escape }}</p>
  <div class="actions">
    {% if platform.github_url and platform.github_url != '' %}
    <a class="button" href="{{ platform.github_url | escape }}" rel="noopener noreferrer">View source on GitHub ↗</a>
    {% endif %}
    {% if platform.video_url and platform.video_url != '' %}
    <a class="text-link" href="{{ platform.video_url | escape }}" rel="noopener noreferrer">Watch on YouTube ↗</a>
    {% endif %}
  </div>
</section>

{% if platform.video_id and platform.video_id != '' %}
<section class="section" aria-labelledby="platform-demo-title">
  <div class="section-heading">
    <div><p class="eyebrow">PLATFORM DEMONSTRATION</p><h2 id="platform-demo-title">See ABCDE in action</h2></div>
  </div>
  <div class="platform-video">
    <iframe src="https://www.youtube-nocookie.com/embed/{{ platform.video_id | escape }}" title="{{ platform.video_title | escape }}" loading="lazy" referrerpolicy="strict-origin-when-cross-origin" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
  </div>
  <p class="small"><a href="{{ platform.video_url | escape }}" rel="noopener noreferrer">Open the demonstration on YouTube ↗</a></p>
</section>
{% endif %}

{% if platform.capabilities.size > 0 %}
<section class="section prose" aria-labelledby="platform-capabilities-title">
  <h2 id="platform-capabilities-title">What the platform supports</h2>
  <ul>{% for capability in platform.capabilities %}<li>{{ capability | escape }}</li>{% endfor %}</ul>
</section>
{% endif %}

{% if platform.architecture_image and platform.architecture_image != '' %}
<section class="section" aria-labelledby="platform-architecture-title">
  <h2 id="platform-architecture-title">Architecture & system workflow</h2>
  <figure class="figure-card">
    <a href="{{ platform.architecture_image | relative_url }}"><img src="{{ platform.architecture_image | relative_url }}" alt="{{ platform.architecture_alt | escape }}" loading="lazy"></a>
    <figcaption>{{ platform.architecture_caption | escape }}</figcaption>
  </figure>
</section>
{% endif %}

{% if platform.screenshots.size > 0 %}
<section class="section" aria-labelledby="platform-screenshots-title">
  <div class="section-heading">
    <div><p class="eyebrow">PLATFORM GALLERY</p><h2 id="platform-screenshots-title">Inside the workspace</h2></div>
    <span class="small">Select an image to view it full size.</span>
  </div>
  <div class="gallery platform-gallery">
    {% for shot in platform.screenshots %}
    <figure>
      <a href="{{ shot.src | relative_url }}"><img src="{{ shot.src | relative_url }}" alt="{{ shot.alt | escape }}" loading="lazy"></a>
      <figcaption>
        <h3>{{ shot.title | default: shot.alt | escape }}</h3>
        <p>{{ shot.caption | escape }}</p>
        {% if shot.version and shot.version != '' %}<span class="small">Version: {{ shot.version | escape }}</span>{% endif %}
        {% if shot.captured_at and shot.captured_at != '' %}<p class="small">Captured <time datetime="{{ shot.captured_at }}">{{ shot.captured_at }}</time></p>{% endif %}
      </figcaption>
    </figure>
    {% endfor %}
  </div>
</section>
{% endif %}
