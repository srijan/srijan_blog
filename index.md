---
layout: default
---
## About

My name is **Srijan Choudhary** and I am a Software Engineer based in Gurgaon, India. After graduating from BITS Pilani, I am currently working at Grey Orange Robotics.

My work focuses on network programming and artificial intelligence.

In my free time, I enjoy [hacking with new technologies](https://github.com/srijan/), and [listening to music](http://www.last.fm/user/srijan4).

## Contact

[srijan4@gmail.com](mailto:srijan4@gmail.com)

## Blog Posts

<ul class="posts">
{% for post in site.posts %}
{% unless post.categories[0] == "notes" %}
<li><span class="fancy">{{ post.date | date: "%B %d, %Y" }}</span> <a href="{{site.baseurl}}{{ post.url }}">{{ post.title }}</a></li>
{% endunless %}
{% endfor %}
</ul>

## Notes

<ul class="posts">
{% for post in site.categories.notes %}
<li><span class="fancy">{{ post.date | date: "%B %d, %Y" }}</span> <a href="{{site.baseurl}}{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>

You can also browse through specific topics via [the tags list]({{ site.baseurl }}/tags.html "Tags List")
