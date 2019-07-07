---
title: "Sentence Banking"
date: 2019-07-07T16:05:15+02:00
draft: false
---

This is a post about a [ginkou](https://github.com/cronokirby/ginkou), a tool I made
recently. This tool combines Rust, SQLite, as well as a [mecab](http://taku910.github.io/mecab/)
in order to archive sentences and retrieve them based on the words they contain.

## Why would I need this?

Unless you're learning Japanese, you probably don't. With the way I'm going about learning,
I try and combine words and grammar into the same flashcard system. This involves making new
flashcards with sentences containing small bits of information I'm trying to learn. These new pieces
of information can be new words or grammar. By keeping information in full sentences, everything
is learned in context.

Sometimes, a new word is encountered without an accompanying sentence, or in a sentence that contains
too many parts that are unknown as well. Since we want a sentence where just that word is new, we'd
like to easily find sentences containing that word. **Ginkou** aims to accomplish this by letting
us build up a bank of sentences, and then search these sentences for examples containing a specific
word.

## Bird's eye view

**Ginkou** has two main operations: **add** and **get**.

The **add** operation takes a textual source, such as a text file, or sentences written from the
command line, and then adds those to the bank. This operation will first parse the file into its constituent
sentences. Then it splits each sentence into the list of words it contains, using **mecab**. By using **mecab**
instead of naive splitting, we can use the root form for conjugated verbs, instead of the form it happens to appear
in. This is useful for verbs, where we want to find sentences containing a conjugated form of that verb.

Now that we have a sentence and a list of words in that sentence, we can store the sentence in a table, and the words
in another table. We also use a junction table in order to represent the many-to-many relationship between
words and sentences.

The **get** operation looks up the sentences containing a given word. This operation makes use of the junction table
we used in the previous operation. Through a beefy statement containing a few joins, which we'll see later in this post,
we can get all the sentences that contain a given word.

## Why Rust?

I like going to Rust for small command line tools because it lets me easily write tools that
work efficiently without much effort on my part. Rust has good libraries for parsing command line
operations and interacting with things like SQLite.

## Table Structure

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

These are fairly standard, but let's notice that we impose a unique constraint on the words but not the sentences.
When inserting into the words table, we have to take care to not insert a word if it already exists in the table.

Next we have the scary junction table to model the many-to-many relationship:

```sql
CREATE TABLE WordSentence(
    word_id INTEGER NOT NULL,
    sentence_id INTEGER NOT NULL,
    PRIMARY KEY(word_id, sentence_id),
    FOREIGN KEY(word_id) REFERENCES Words(id),
    FOREIGN KEY(sentence_id) REFERENCES Sentences(id)
);
```

The table just contains 2 columns, one containing keys referencing words, and the other containing
keys referencing sentences. The rest of the declaration is just making sure that the keys we insert into the table are pairwise
unique, and correctly reference things in the other tables.

To illustrate how this table works, let's take a sentence 猫を見た containing the words 猫, を, and 見る (見た is the past tense of 見る).
After doing all our operations on an empty database, we'd end up with the following situation:

**Words**

```
id word
-- ----
1  猫
2  を
3  見る
```

**Sentences**

```
id sentence
-- --------
1  猫を見た
```

**WordSentence**

```
word_id sentence_id
------- -----------
1       1
2       1
3       1
```

### Big scary statements

The trickiest statement to write was for the `get` operation. This statement needs
to look up all the sentences containing a specific word. To do this we need to make use
of the Junction table we previously populated, and use it to join our sentences with the words
they contain. Once we have a table with rows containing a sentence and a word it contains, we can simply
filter for rows containing the right word, and take out the sentence.

The statement looks like this:

```sql
SELECT sentence FROM sentences
LEFT JOIN wordsentence ON wordsentence.sentence_id = sentences.id
LEFT JOIN words ON words.id = wordsentence.word_id
WHERE word=?1;
```

I think we could have used an **Inner Join** as well, but since we're checking with equality
on a word, the NULLs that appear because of a **Left Join** don't matter.

## Why SQLite?

The main advantage of using SQLite was the ability to transfer the bank between computers easily.
Since SQLite keeps a database in a single file, we can simply transfer the file from one place to another.
Integrating SQLite is also much easier in a standalone application, as we don't need to worry about starting
the database in the background. All we need to do is have a file for SQLite to work with.

## Disks are slow

On the first iteration of the program, consuming sentences was very slow: the program was only capable
of adding 3 sentences per second or so. The culprit turned out to be how SQLite was used.

When SQLite was used with an in memory database instead of an on-disk one, the processing rate
went up to 1000 sentences per second. Every time we added a sentence, we had to process a few
SQL statements on the database. With an on file database, this meant hitting the disk for every sentence, which
was quite slow.

In order to take advantage of the speed of in memory transactions, while still having a final database on disk,
I used SQLite's transactions, which allow us to perform a bunch of operations in memory, before finally committing
them to the real database on disk.

## Final Remarks
This post was just to share a few thoughts and snippets of what went into this little project.
Hopefully there was something to learn from it. The curious can check out the code over
[here](https://github.com/cronokirby/ginkou).
