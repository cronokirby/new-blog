---
title: "Bittrickle"
date: 2019-02-26
tech:
  - "Rust"
  - "Networking"
withpost: false
description: "UDP Bittorrent Tracker"
link: "https://github.com/cronokirby/bittrickle"
---

**Bittrickle** is an implementation of Bittorrent's UDP tracker protocol. A tracker keeps
track of peers participating in a bittorrent swarms, sharing files. Peers communicate with
the tracker in order to learn about each other. This implementation uses *Rust* because of its
built-in UDP networking.
<!--more-->