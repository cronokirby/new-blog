---
title: "Ginkou"
date: 2019-06-28T20:55:57+02:00
tech:
  - "Rust"
  - "SQLite"
withpost: false
description: "Japanese Sentence Bank"
link: "https://github.com/cronokirby/ginkou"
---

**Ginkou** is a program to build up a corpus of searchable sentences.
**Ginkou** can consume Japanese sentences from the command line, or from a text
file, parse those sentences into words, and then index those sentences for
easy retrieval. Given a word, **Ginkou** can look up sentences containing
that word, even if it's in a different form, such as a conjugated verb.
<!--more-->
## Why would I need this
Unless you're learning Japanese, you probably don't need this. On the other hand,
this is an invaluable tool if you are. The main utility comes from easily finding
example sentences for a new word you're trying to learn. Example sentences are cleary
useful tool for learning new vocabulary, but they're also the crux of *sentence mining*.

Sentence mining involves learning new vocabulary and grammar through context, by searching
for sentences with new information, and learning that new information in the context of these
sentences instead of as isolated pieces.

Sometimes you encounter a word you want to learn, either without an accompanying sentence, or with
a sentence containing too many other missing pieces. In this case, having a bank of sentences to look
up examples for this new word is very useful.

## Using SQLite as a sentence bank

For this application I had a few simple tasks I needed in a storage system:
- Storing sentences, along with a list of words they contain
- Storing words
- Being able to look up the sentences containing a given word.

I decided to go with SQLite because my needs only required 3 tables and a handful of queries,
and the ability to just have a single file for the database made packaging up the functionality
into a standalone CLI program much easier. Using SQLite is also quite fast, since when adding
many sentences, we can do all of those operations as a transaction, running in memory, allowing
us to spare disk IO for the few final steps of consuming a file. Hitting the disk for every sentence
in a Japanese file meant processing around 1 sentence per second, but switching to in memory transactions
meant more than 2000 sentences per second.

Having a single file is also convenient for users, since they can send the bank to other devices easily,
or start with a clean slate simply by deleting their database file.

The sentences and the words map neatly onto database tables, with a single column needed, outside the
primary key, of course.


## Parsing sentences with mecab
The program 