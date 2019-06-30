---
title: "Populate"
date: 2018-11-07
tech:
  - "Haskell"
  - "FFmpeg"
  - "Rest APIs"
description: "Music Library Cloner"
withpost: false
link: "https://github.com/cronokirby/populate"
---

This is a CLI program that can recreate a music library on a new machine by downloading
the files from various sources across the web. The program parses a file
with a hierarchical description of the library to replicate , and reproduces
that structure by consuming the sources described.
The program can also split up larger albums (via FFmpeg) into individual songs if necessary.
<!--more-->