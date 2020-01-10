---
title: "Integrating Notes and SRS"
description: "Some rough ideas on how to join integrated notes and spaced repetition"
date: 2020-01-10
draft: false
tags:
  - Learning
  - SRS
---

This is a rough braindump about a project I've been thinking about recently.

# A better way of using notes?

So i've been tinkering around with better systems for taking notes recently. I'm not a big
fan of keeping notes, around because I don't find myself actually revisiting them, and when I do,
I don't get much value out of it. On the other hand, my experience with language learning has definitely
showed me how effective spaced repetition is when it comes to keeping things in your head.

So it's not that notes are completely useless, but rather that the main value I get out of
them is in making them. Making notes, especially after having followed a lecture, forces me
to organize that information. It'd be nice to use this effort to feed into an SRS system,
to also get the benefit of not losing that information over time

## What it might look like

It'd be nice to have a system that allows you to take notes, and also include snippets to enter into
an SRS system automatically, and this is exactly the thing I've been tinkering around with recently.
Right now, I'm just at the phase where I'm thinking of how to even organise data structured in this way.

One goal I'd like to preserve is that the notes themselves, along with the SRS snippets they contain,
should be text files, and worked on through your favorite editor. I don't really want to get into
creating an integrated web editor right now.

Because of this, all the information about SRS snippets needs to be included there as well.

### SRS snippets

SRS snippets can be very general, but there needs to be three things:

  1. Some kind of prompt, that asks you to recall information
  2. The information you were supposed to recall
  3. (Optionally) extra data to accompany that information

The main point of SRS snippets is to be able to have flashcard like things to recall periodically.
The SRS part is about spacing the reminders for this snippets in order to keep them fresh in memory.

Now, you could generate SRS snippets from the text automatically, but that's not the simplest
thing, now is it? You also want to have decent control over these things, and this isn't
the best way to do that either.

### Sections

I have two primary use cases in mind for sections.

I like making big summaries for courses I'm taking. For example, writing up a nice organised summary
on a Electromagnetism. I want this summary to appear as a single section, instead of disorganised sections.

On the other hand, I also like working on a lot of different smaller things over
the course of a day. I also have subjects where my thoughts aren't organised into large summaries,
but rather small snippets orbiting around the topic.

For these, it's better to have invidual sections that are always shown together, and then you can organise
all of the sections related to a topic together.

### Other concerns

You also want to be able to include things like, math (via LaTeX), code highlighting, images, etc.
And you want to be able to structure the notes the way you would if you were writing it all in pure markdown.

I think that this makes markdown a good starting point for this kind of system. You can easily
extend it with extra syntax for handling sections and what not. Another Idea I had is that it's likely
better to encode most of the information inside the section headers themselves.

My main reason
coming from how I use physical notebooks. I've come to prefer just working in a single notebook,
in a linear fashion, writing down whenever I switch to a different context.
I want to keep this way of working, even as I work on different things. To this effect, I might end
up keeping a daily log, filled with a bunch of sections. The system would end up filtering and sorting
these different sections into the correct topics afterwards.

Because of this filtering and partitioning system, it doesn't make much sense to place too much weight on the
filesystem. The hierarchy that you might infer from the filesystem might not actually be reflected on what sections
exist and the topics they talk about. I think it's best to ditch a strict reliance on organising based
on files, and instead focus on sections, and then let people organize their sections however they please.

# What syntax should we use?

A lot of markdown files include a header section allowing YAML (this one included):

### Sections

```
---
title: "Integrating Notes and SRS"
---

The content of the post
```

I think it's a good idea to reuse this as a section header. The main difference is that we allow parsing this anywhere
in the file instead of just at the beginning.

We keep treating the content we see as part of that section until we reach

- The end of the file
- The beginning of a new section

A section header might end up looking like this:

```
---
section: "My beautiful section"
description: "This is a summary about computational mechanics"
tags:
  - Physics
  - Programming
---
```

### SRS snippets

For the SRS snippets, you want a way of specifying the prompt and information / extra sections.
I've been thinking of doing it like this:

```
--?
# This is valid markdown

And a question?
--!

Here's the answer.

**still valid markdown**
--?
```

This is a spin off the section header. It's nice to have similar syntax, in my opinion, because it avoids adding
too much unnatural syntax to what's supposed to more or less be readable in raw form. The point of using
markdown over JSON is that you can read the markdown file ignoring the extra syntax and get a pretty legible
experience. Trying that with JSON is going to yield a "fun time".

# What should we output?

In the end, I think providing a website is the best way to have an interactive way of exploring things.
It's also what I would've ended up going for even without interactivity, as I think getting things to look
nice is easier there, as much as people complain about CSS. In the end, I do think having a nice presentation
for information makes things easier.

So if we're doing a website in 2020, we're going to have to quickly navigate
the fork in the road between static rendering, and using a Javascript framework of some kind.

With static rendering, we'd generate all the ways of organising this information in advance, and then the website
would link between everything. The downside of this is that we're fixed into a constrained way of doing things,
and we can't easily filter based on user inputs.

With a Javascript, the website is our oyster when it comes to organising what we see.
I also enjoy working with Javascript frameworks, so that's probably going to be what I end up doing.

To that end, we should generate some encoding of the sections that's easier to use in a programming language,
like JSON, for example. With a bunch of JSON files generated we can serve those statically, along
with the Javascript bundle generated by our frontend framework. The application than consists of these two parts.

I also plan on this being a relatively personal tool, which makes it

# Persistence

In order to make the SRS work, we need to integrate some kind of quizzing into the frontend application.
We also need to store the results of these quizzes somewhere on the user's computer. In these cases, where
I'm storing some kind of persistent state for an end application, SQLite is my go-to. The nice thing with SQLite
is that everything goes into a single file. This makes syncing between devices possible just by copying the database
file over (it shouldn't ever grow that large, if we don't store the actual questions in the database).

As for the actual text files themselves, I would end up keeping them in version control(you could put the SQLite DB in here too).
This allows you to share your notes on things with other people too, which can be a plus.

# More to come

Well this was just a braindump as a start form some thoughts about this project. I thought I might
as well put this on my blog, because it's a bit lacking in posts, and I think some people might gain some benefit from it.
