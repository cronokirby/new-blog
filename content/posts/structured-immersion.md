---
title: "Structured Immersion"
date: 2019-12-28T13:13:00+01:00
draft: false
tags:
  - "Japanese"
  - "Programming"
---
(Note: this is a first draft, and subject to change)

When it comes to language learning, one approach that I really subscribe to is immersion.
This means trying to absorb as much of the language as possible, as often as possible.
It's often said that "speaking with locals" is a good way to accelerate the learning process,
and there's a lot of truth with that statement.

### Comprehensible Input

One aspect of immersion that's often overlooked is the idea of *comprehensible input*. The idea
is that the input you get in your target language is more useful if it's understandable despite
your lack of knowledge of some words or grammar. Those new language points can be assimilated because
the entire message remains comprehensible because of context, other language points you do know,
or other cues such as gestures or video.

For example, if you're trying to learn Japanese, watching anime can be great (provided you don't use subtitles),
because the language used can be simple enough to understand based on the visuals on the screen.
If you can guess what people would be saying with just a few key words, then that's a good candidate
for comprehensible input, even if you don't understand most of the actual Japanese.

### Comprehensibility varies

Now, not all input is very good at being comprehensible. At the beginning, most native media
will be too difficult to be effective. If you only understand 10% of the sentences in some piece of media,
you're not going to be doing much learning with that source. Conversely, as you advance, media you completely
understand won't teach you new pieces of language, although it does help you solidify your understanding
of the language, and can help with things like pronunciation and choosing native-sounding phrasing.

Even worse is that it can actually be difficult to tell whether or not a piece of media is
at the right level before actually consuming it. Even if that piece of media is aimed at a native
audience with a similar language level to your own, it's possible that the topic might be one where
you're lacking a lot of vocabulary.

### Context matters

For example, even if you've watched a lot of anime aimed at young teenagers, if you start watching
a piece of science fiction aimed at the same audience, it's possible to be lacking most of the vocabulary
they'll be using. The common, everyday phrases may be engrained, but space exploration / giant robot
jargon is likely to be completely lost on you.

Furthermore, if identifying whether or not a piece of media is going to make for good learning
is hard, then finding that media in the first place is even harder. Of course, my recommendation
would be primarily to focus on media you enjoy consuming anyways. After all, the point
of learning a foreign language as a hobby is to have fun, isn't it.

Even then, being able to organise the media you plan on consuming based on how appropriate
it would be for your level of language would help immensely in expediting the learning process.
If you could know which show to watch next based on what your current vocabulary is, that would
save a lot of time, and make immersing a lot easier.

With immersion, it's about `quantity * quality`, so you want to make it as easy as possible
to get a lot of good quality (i.e. level appropriate) media.

## Tracking progress

One aspect of this problem that I've briefly gone over without expliciting is tracking your
progress. In order to provide such a structure, and know what media to consume next, you need
to keep good tabs on how much language you know, and the topics where your vocabulary is lacking.
Often people will use flashcard systems like Anki in order to keep track of their progress,
but mainly to remind themselves of old vocabulary to make sure they don't forget it. The problem
is that manual entries need to be created and entered into this flashcard system, even though media is often
consumed in a way where it could be entered manually.

Well, that's the introduction to some of the problems in the space of language immersion, and thankfully I think
a good deal of them can actually be addressed, thanks to the most media being digital nowadays.
Well, at least, the cheapest (free) and most easily accessible native media is going to be digital
and available on the internet.

## An ideal immersion process

Ideally, here's what the daily immersion process would look like:

You arrive at the "dashboard" and have a list of media you can consume. You simply dedicate as much
time as you want that day to consuming it: you read and watch as much as you want to that day.
The media is recommended to you based on how appropriate it is for your immersion, given your current
language level. The media will have a right amount of new vocabulary and grammar to keep you stimulated
and learning, but not enough to drown you in unknown topics. Additionally, your progress is updated
based on that media you've consumed. There's no need to manually enter the new words or grammar points
that you learned.

### Flashcard systems

Furthermore, the system can act as a flashcard system like Anki, where you automatically review the vocabulary
you previously learned, in order to make sure it stays fresh and accessible in your mind.
I won't go into the benefit of spaced-repetition systems like Anki, but for those that do benefit from them,
having automatic entries is indeed quite convenient.

I think that you could actually make a system providing that functionality to users.
You could keep track of a user's progress in their target language, and use that to source media
that they immerse in, and that you use to keep track of their ongoing progress.

The crux of this whole process is keeping track of a user's progress in a language. Without this
feature, none of the others are possible. All of those other aspects are consequences of exploiting
this key feature to the fullest extent.

### Saving manual work

When a user sources new media for themselves, they're using their knowledge of their own progress
in order to judge whether or not that media is comprehensible enough for them. And when they're entering
new sentences into their flashcard system, they're copying over the new vocabulary from that media.
This is done, once again, using thier knowledge of their own learning process. By keeping track of
this progress in an automated fashion, we can in turn automate so many aspects of the immersion process.

## Is this all just a pipe dream?

Now, that's a high level overview behind the idea behind such a system, but how feasible would
a system of this kind be? In all honesty, I'm not sure if this scales to any language. I'm not
even confident it would work as well for English as it would for Japanese. On the other hand,
Japanese is structured enough to make grammatical analysis quite easy.
Different langauges have different ways of building up sentences, which can make figuring out what
the user does and does not know in that sentence more or less difficult. Another difficulty relates
to figuring out what's comprehensible in a smart way, as we'll see later.

## It might not be for Japanese

So, let's look at how realistic such a system could be, through the lens of Japanese.

Now, one of the core components of this system is figuring out what language concepts
are in a given sentence. Now, I've been using the *sentence* as a basic building block of media,
and it's a good unit for splitting large bits of text. Thankfully, Japanese sentences are marked by punctuation
in actual text, and multiple lines of dialogue are easy to split even without punctuation.

### Luckily simple

Japanese morphology is simple, or regular enough in order to split sentences into words in quite a consistent
way. There are a handful of tools, but the one I've used most recently was
[MeCab](http://taku910.github.io/mecab/).

This tool takes the form of a command line program, that accepts a stream of sentences. The output of the tool
looks like this:

```
$ mecab
猫は食べた
猫	名詞,一般,*,*,*,*,猫,ネコ,ネコ
は	助詞,係助詞,*,*,*,*,は,ハ,ワ
食べ	動詞,自立,*,*,一段,連用形,食べる,タベ,タベ
た	助動詞,*,*,*,特殊・タ,基本形,た,タ,タ
EOS
```

The first line is our sentence, "猫は食べた", literally "The cat ate". The next lines are the different words
MeCab managed to find throughout that sentence, along with their pronunciation, their part of speech, etc.
For example, the first word it gives us is "猫" meaning "cat". It tells is that it's a noun, pronounced "neko", etc.

Using MeCab, you can quite easily split native media into the words that compose it. This makes it easy to take all the "new" words
based on this classification, and add them to your flashcard system, along with the surrounding context.
Generally, you want the surrounding sentence for a given word in a flashcard system, but that's really another discussion entirely.

### Except for grammar

One tricky thing that MeCab doesn't take care of, and that I haven't completely looked into solving is figuring out what grammatical
components figure in a given sentence. As we've just seen, it's quite easy to get the words in a Japanese sentence out, but it
seems much harder to get grammar out. There are *some* things you can do. For example, that last sentence used the past tense,
and MeCab considers the past conjugation to be a word, for some reason, so you can pick up on cues like that.

## What is comprehensible enough?

Now, another problem is when to consider a piece of media suitable for consumption. Taking a sentence based approach seems
appropriate at a first glance. That is to say, we can classify each sentence with a certain comprehensibility score,
and then aggregate that score throughout the whole text, to get an overall score. We can then use that score to
rank the different pieces of media we've managed to source previously. We would also reject pieces of media
that are too comprehensible.

One simple metric would be to look at what percentage of words are known in a given sentence the user knows.
The problem with this metric comes from its simplicity: it doesn't take into account the surrounding context,
nor how easy some words are to guess. I don't have many ideas for the time being to go beyond this simple metric
however.

### User input

Other approaches could include user input on whether or not they understood a sentence despite not knowing the
words in that sentence. You could use that to suggest similar sentences.

That being said, even a simple metric would help immensely in ranking texts, as comprehensibility doesn't need to
be exact to be beneficial. Even ranking materials just on the words you don't know would help immensely with triaging
all the media you have available.

## Sourcing media

Now we come to the problem of sourcing media.

An advanced approach would be to scrape the web for material and build up a gigantic database of native media.
Although impressive and expansive, this approach would also be expensive, and fail to satisfy a key criteria:
providing media the user is actually interested in.

As mentioned before, having media the user actually wants to consume is actually important in keeping the
language learning process from becoming a long march of boredom.

### Accepting user submissions

An easier approach that also satisfies this criterion is accepting texts from user input. The user can submit
text from subtitles or books they're reading, along with whatever sources they want to consume eventually.
The system would also need to keep track of the order of certain texts, because for certain things, like books, you might
want to read them in a linear order. In order to help with the fun of immersion, you want to respect ordering like this.
Respecting the chronological order of media also helps with understanding that media. Obviously,
for serial media, understanding the story requires having understood most of the previous parts
of the story.

This approach is also easier, because we don't have to worry about sourcing the material, and can instead
rely on the user providing us with material on their own. This is similar to how [](japanese.io) works,
where you enter text into their site, and then it augments it with dictionary entries and what not.

## Presenting media

Another thing I'd like to touch on is how you present this media to the user. One disadvantage to this text based
approach is that the user has to read. What you get out of it is that you can track the progress
of the user in the media, and thus enter these new words automatically.

### Augmented immersion

When presenting text to the user, you can augment it without know the user's progress, adding
things like an automatic dictionary, sentence, copying, etc. You can use the user's progress to highlight words they
don't know. You can add the words they read to the flashcard system. You can also take into account their use
of the built-in dictionary while reading the text in order to update the flashcard system.
If they've looked up a word, they don't know it as well as previously thought, so that word needs to be bumped
up the flashcard stack.

You could also just rank the pieces of media, and then let the user read them on their own time.
The disadvantage there would be losing the augmented reading experience, as well as not being able
to automatically track progress. For example, if the user is reading a novel through the augmented
portal, you can track their position and language progress through the book. If they read it on their own,
you don't know how far they've gotten to the book. You could let them tell you when they've finished the whole
book, but adding that large chunk of language after the fact isn't as useful.

## Conclusion

To wrap things up, I think that immersion is very important for learning a foreign language, and that
making immersion as easy as possible helps making learning even easier. Having a system that
keeps track of your progress in a language can help save you time in learning and revising vocabulary,
and can help triage and augment the immersion process.
