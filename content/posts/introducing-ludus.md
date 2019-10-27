---
title: "Introducing Ludus"
date: 2019-06-13T21:35:12+02:00
draft: false
tags:
  - Rust
  - Emulation
---

This is a short post about a crate I recently published:
https://crates.io/crates/ludus. This crate provides the core logic of an NES
emulator, and can be used to build independent GUI applications.

Ludus started out as a standalone NES emulator, back in October of 2018.
At that point, I had gotten a completely working emulator, aside from
some pretty glaring audio issues. I wanted to revisit it at some point, in
order to fix the audio.

I recently had time to do so, so I went in and cleaned up the code base a bit,
and ended up finding the causes of the audio bugs.

The first thing I did was running
[clippy](https://github.com/rust-lang/rust-clippy)
on the entire codebase, and found quite a few issues. The main issue had
to do with a clippy warning for up-casts like:

```rs
let x: u8;
x as u16;
```

Clippy doesn't like this because it can introduce implicit truncation if
the type of `x` ever grew larger. These types of casts appear very frequently
throughout the emulator.

That being said, clippy actually did find the bugs in the APU causing the audio
glitches:

```rs
if x & 040 == 0x40
```

This code was flagged as being an impossible check, rightly so. There were a handful
of issues like this in the APU causing weird behavior, fixing all the clippy
checks thankfully solved all the audio issues.

After cleaning up the emulator, and fixing these audio bugs after so long,
I decided to go ahead and work on one of the mappers I hadn't added yet.
I added `iNES1` which is the mapper used for games like
`Zelda` and `Final Fantasy`.

At that point I wanted to experiment with different audio and video backends,
although I ended up sticking with [minifb](https://crates.io/crates/minifb)
for video, and [cpal](https://crates.io/crates/cpal) for audio.

To make that easier, I ended up creating traits for the video and audio devices,
and made the core logic of the emulator depend on traits, instead of the
concrete video and audio structs that were needed:

```rs
trait VideoDevice {
    fn blit_pixels(&mut self, pixels: &PixelBuffer)
}

trait AudioDevice {
    fn push_sample(&mut self, sample: f32)
}
```

At that point I realised that the core of the emulator could be split off from
the rest of the crate that depended on specific backend logic. The core logic
crate doesn't even have any dependencies, which is very nice. It could possibly
work with `#[no_std]` but I haven't looked into that at all.

The application you can use to play games is available
[here](https://github.com/cronokirby/ludus-emu).

The standalone crate can be used to create your own NES emulator applications,
and is available [here](https://crates.io/crates/ludus).
