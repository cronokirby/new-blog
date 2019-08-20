---
title: "Sentence Banking"
date: 2019-07-07
draft: false
tags:
  - Japanese
  - Rust
---

This is a post about [ginkou](https://github.com/cronokirby/ginkou), a tool I
made recently. This tool uses Rust, SQLite, as well as
[mecab](http://taku910.github.io/mecab/) to archive sentences, and then to
retrieve them based on the words they contain.

# Why would I need this?
Unless you're learning Japanese, you probably won't.

With the way I'm approaching it, I try and combine words and grammar into the
same flashcard system. This means making new flashcarsd with sentences
containing small bits of information I'm trying to learn. These can be new words
of grammar. By keeping information in full sentences, everything is learned in context.

A new words is sometimes encountered without an accompanying sentence, or in a
sentence that contain too many unknown parts. We want a sentence where just that
word is new, so we'd like to easily find sentences containing that word.

**Ginkou** makes finding these examples sentences easy. The program is used to
first build up a bank of sentences, and then to retrieve sentences from that
bank based on the words they contain.

# Bird's eye view
**Ginkou** has two main operations: **add** and **get**.

The **add** operation takes text, either from a file, or from the command line,
and then adds those to the bank. This operation will first parse the input into
sentences. Then it splits each sentence into a list of words, using **mecab**.
Using **mecab** instead of naive splitting lets us use the root from for
conjugated verbs. Naively splitting would use the form the verb happens to be
conjugated in.

We then store the sentence in one table, and each word in that sentence in
another. We then add a link in a junction table for each word. Each link
specifies that a word `W` appears in a sentence `S`. This table is used to
represent the *many-to-many* relationship between words and sentences.

The **get** operation looks up the sentences containing a given word. This
operation uses the junction table built up with the **add** operation.
Implementing this operation requires a bit of *SQL* statement savvy, which we'll explore later in
this post.

# Why Rust?
I like using *Rust* for small command line tools. It has a bit of a learning
curve, but is easy to use after that. The tools tend to work efficiently without
having to pine much over performance. *Rust* also has good libraries for parsing
command line arguments, and for using *SQLite*.

# Why SQLite?
One advantage of using SQLite was the ability to transfer the bank between
computers easily. Since SQLite keeps a database in a single file,
we can simply transfer the file from one place to another.

Integrating SQLite is also much easier in a standalone application,
as we don’t need to worry about starting the database in the background.
All we need to do is have a file for SQLite to work with.

# Table Structure
In this section we'll go over what our database schema looks like.

We have a table for each word, and a table for each sentence:

```sql
CREATE TABLE Words(
    id INTEGER PRIMARY KEY,
    word TEXT UNIQUE NOT NULL
);

CREATE TABLE Sentences(
    id INTEGER PRIMARY KEY,
    sentence TEXT NOT NULL
);
```

Each table uses an integer as its primary key. Both tables then store text in
the other column. We don't want to avoid storing duplicate words, so we add a
`UNIQUE` constraint to that column. To avoid errors, we need to make sure to
only insert new words into the table.

Next we have the junction table modelling the *many-to-many* relationship:
```sql
CREATE TABLE WordSentence(
    word_id INTEGER NOT NULL,
    sentence_id INTEGER NOT NULL,
    PRIMARY KEY(word_id, sentence_id),
    FOREIGN KEY(word_id) REFERENCES Words(id),
    FOREIGN KEY(sentence_id) REFERENCES Sentences(id)
);
```
This table only contains 2 columns, one referencing words, and the other
referencing sentences. The rest of the schema makes sure that the keys inserted
into the table come in unique pairs, and that they reference keys that exist in
the other tables.

## Example usage

To illustrate how this table works, let's look at an example sentence. The
sentence "猫を見た" contains the following words: 猫, を, and 見る. (見た is the
past tense of 見る). Adding this sentence to an empty database will give us the
following tables:

**Words**:
```sql
id word
-- ----
1  猫
2  を
3  見る
```

**Sentences**

```sql
id sentence
-- --------
1  猫を見た
```

**WordSentence**
```sql
word_id sentence_id
------- -----------
1       1
2       1
3       1
```

For each word, we've created a link in the junction table representing the word
belonging to the first sentence in our newly populated sentence table.

## Big Scary Statements
The trickiest statement to write was for the `get` operation. 
This statement needs to look up all the sentences containing a specific word.
To do this we make use of the Junction table we previously populated,
joining our sentences with the words they contain.
Once we have a table of rows with a sentence and a word,
we can filter for rows containing the right word, and take out the sentence.

The statement looks like this:
```sql
SELECT sentence FROM sentences
LEFT JOIN wordsentence ON wordsentence.sentence_id = sentences.id
LEFT JOIN words ON words.id = wordsentence.word_id
WHERE word=?1;
```

I think we could have used an *Inner Join* as well,
but since we’re checking with equality on a word,
the `NULL`s that appear because of a *Left Join* don’t matter.

# Disks are slow
On the first iteration of the program, consuming sentences was very slow:
the program was only capable of adding 3 sentences per second or so.
The culprit turned out to be how SQLite was used.

When SQLite was used with an in memory database instead of an on-disk one,
the processing rate went up to 1000 sentences per second.
Every time we added a sentence, we had to process a few SQL statements on the
database. With an on file database, this meant hitting the disk for every sentence, which was quite slow.

In order to take advantage of the speed of in memory transactions,
while still having a final database on disk, I used SQLite’s transactions,
which allow us to perform a bunch of operations in memory,
before finally committing them to the real database on disk.

# Final Remarks
This post was just to share a few thoughts and snippets of what went into this
little project. Hopefully there was something to learn from it.
The curious can check out the code over [here](https://github.com/cronokirby/ginkou).

