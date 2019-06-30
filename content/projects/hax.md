---
title: "Hax"
date: 2018-10-01
tech:
  - "Haskell"
  - "SDL"
withpost: false
description: "Bullet Hell Game"
link: "https://github.com/cronokirby/hax"
---

**Hax** is a bullet hell game, in the same vein as others like *Touhou* or *Ikaruga*.
The game is written in Haskell, using SDL for handling the drawing logic. The game
logic benefits greatly from the use of an entity component system for handling the many entities
in the game. [Apecs](https://hackage.haskell.org/package/apecs) was used to provide the scaffolding
for this ECS.
<!--more-->