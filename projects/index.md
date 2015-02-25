---
layout: page
title: Projects
permalink: /projects/
type: page
---

Here you'll find some of my projects that I've been (or currently) working on.

Enjoy:

{% for project in site.collections %}
*  {{ project.name }}
   {{ project.description }}
   {{ project }}
{% endfor %}