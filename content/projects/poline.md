---
title: "Poline"
date: 2019-08-16
tech:
  - "Rust"
  - "Programming Languages"
description: "Tiny Language with Green Threading"
withpost: false
link: "https://github.com/cronokirby/poline"
---
Poline is a little programming language I wrote to learn
about implementing Green Threading. The language
doesn't feature much more than string litterals, and mechanisms
for spawning threads and communicating between them.

Green Threads allow many logical threads in a program to
execute on a limited number of actual OS threads. They
can be preempted off if they invoke a blocking operation.
<!--more-->
