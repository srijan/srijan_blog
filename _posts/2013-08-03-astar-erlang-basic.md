---
layout: post
title: Basic implementation of A* in Erlang
tags: [erlang, pathfinding, programming]
categories: [programming]
published: true
---

Recently I had to write some path finding algorithms in Erlang. The first version I chose was A\*. But, there is no easy way to implent A\* in a distributed way. So, this is the simplest implementation possible. I may rewrite it later if I find a better way.

This code is mostly a modified version of [this one](http://stevegilham.blogspot.in/2008/10/first-refactoring-of-star-in-erlang.html).

The code hosted on gist follows below, followed by some notes.

{% gistnocache 6142366 astar.erl %}

### Notes

* Variables `MINX`, `MINY`, `MAXX` and `MAXY` can be modified to increase the size of the map. The function `neighbour_nodes/2` can be modified to add obstacles.

* To test, enter in erlang shell:

      c(astar).
      astar:astar({1, 1}, {10, 10}).

* The `cnode()` structure represents some sort of coordinate. To use some other structure, the functions `neighbour_nodes/2`, `h_score/2`, and `distance_between/2` have to be modified for the new structure.

* The current heuristic does not penalize for turns, so the resultant path tends to follow a diagonal looking shape. For correcting this, either diagonal movements can be allowed (by modifying the neighbours function), or turning could be penalized in the heuristic function (current direction would have to be tracked).
