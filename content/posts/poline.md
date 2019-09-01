---
title: "Poline"
date: 2019-08-31T19:18:13-04:00
draft: false
tags:
  - Rust
  - Programming Languages
  - Concurrency
---
*(Note: this is a first draft)*

This is a post about [Poline](https://github.com/cronokirby/poline), a tiny
programming language I wrote recently. The main "gimmick" of Poline is
a feature called *Green Threads*. In fact, Poline doesn't have many other
features besides them.

# Green what?
[Green Threads](https://en.wikipedia.org/wiki/Green_threads) are a way of
managing concurrency. The core idea is to have many lightweight threads
scheduled over fewer OS threads. These tiny threads are then managed by
the runtime itself, instead of the OS.

## Preemptive Scheduling
Languages like Go, as well as Poline, do preemptive scheduling for their
threads. The runtime knows when a given thread is performing a blocking
operation, and can "preempt" that thread in order to run others. For example,
when a thread is reading from a TCP socket, the runtime can switch off to other
threads if no data has arrived yet.

## Messaging
Having independent threads is nice in and of itself, especially when combined
with preemption, but threads also want to communicate with eachother.

In languages like Go, threads must communicate through explicit interfaces
called *channels*. A channel first needs to be created and then given to
both threads before they can communicate to eachother across it. In Go,
multiple threads can be sending messages on a channel, and multiple threads
can be pulling messages from that channel.

Other languages, such as Erlang and Poline itself, instead allow communication
between threads directly. In Poline, creating a new thread also gives us a
handle, which we can use to send messages to that thread. The thread itself can
wait until it receives messages sent directly to it.

## Motivation
My main motivation in writing Poline was to learn how to implement Green
Threading. The impetus was actually a tweet, describing Green Threading as a good interview question.
I wondered how I might implement that feature myself, and decided to tinker with
tiny language. Poline doesn't have many features specifically because I wanted
to focus on this aspect.

# The language itself
Before I go into the implementation of Poline, let's take a look at its syntax.

A Poline program consists of a series of function declarations.
Here's an example of one of these declarations:
```
fn example(arg1, arg2) {
}
```
Each function has a name, and then takes a list of named arguments.

The function called `main`, is the entry point for a program.

## String litterals
The only type of litteral in Poline is the string, which works
the same as other languages:
```
"example string"
```
The only things a variable can contain in Poline are strings, and thread
handles, as we'll see later.

## Printing
Poline has a statement for printing:
```
fn example(arg) {
    print arg;
    print "litteral";
}
```
Both variables, and string litterals can be printed. Every statement
in poline ends with a semicolon. Every function consists of a series
of statements.

## Calling functions
Another type of statement is the function call:
```
fn print(arg) {
    print arg;
}

fn main() {
    print("foo");
}
```
This works as you'd expect. Extra arguments are ignored, and missing arguments
are filled in with empty strings.

## Creating threads
Now we come to the real interesting parts of Poline.

We can create a new thread from a function call:
```
fn print(arg) {
    print arg;
}

fn main() {
    spawn print("a") as p;
}
```
Here, the variable `p` contains the handle for the thread we've spawned.
The thread will run the function it was called with.

## Communicating between threads
Here's an example program that shows how messaging works:
```
fn print_recv() {
    recv arg;
    print arg;
}

fn main() {
    spawn print_recv() as p;
    send "foo" to p;
}
```
After spawning a new thread, we have a handle we can access stored in `p`.
We send the string litteral `"foo"` to `p`. We could have sent a variable
instead of a string litteral too.

In the thread `p`, we first receive a message, creating a variable named
`arg`, and then we print the contents of that variable.

### Preemption
We'll go into the details of this later, but whenever a thread uses `recv`,
it gets preempted until a message is available. When `p` calls `recv` without
a message to fulfill that request, it gets preempted, letting another
thread run. Once a message is sent to `p`, it can be considered again.

Poline is actually deterministic, because it doesn't yet have multithreading.
In this case, `p` will always start running after the main thread finishes,
because the main thread has no blocking `recv` calls that preempt it off.

# Implementation
I decided to implement Poline in *Rust*, mainly because I'm familiar with
the language, and because it has good ways of representing ASTs.

The interpretation pipeline looks like this:
```
Lexing -> Parsing -> Simplifying -> Interpreting
```
The lexing phase separates the raw text into tokens,
making it easier to parser. The parser converts this newly created
series of tokens into an AST representing the program. The simplifier
makes the code easier for the interpreter, by doing things like removing
variable names. And the interpreter is the work horse here, actually
executing the code.

I've taken some care in making the code easier to understand, so I encourage
you to check out the [source](https://github.com/cronokirby/poline)
itself for more details about the implementation.

## Lexing
The [lexer](https://github.com/cronokirby/poline/blob/master/src/parser.rs#L62)
takes the raw text of the program, and converts that into
a series of tokens.

For example, this program:
```
fn main() {
    print "foo";
}
```
gets lexed into:
```
Function Name("main") ( ) { Print String("foo") ; }
```
Dealing with a sequence of tokens instead of raw text makes the parser's job much easier.

The language is simple enough that the lexer can work with just one character of lookahead.
Essentially, our lexer only needs the following operations from our source of
text:
```
// pseudo code
fn next(Source) -> Option<char>
fn peek(Source) -> Option<char>
```
The first function, `next`, will return `None` if we're at the end of our
source, and will otherwise return the next available character, and then advance
that source. For example, given `"12"` as our source, the first call to next
will return `Some('1')`, the next will return `Some('2')`, and subsequent calls
will return `None`.

The difference between `peek`, and `next` is that the former doesn't advance the
source. Given `"12"` as our input, calls to `peek` will always return `Some(1)`,
until we call `next` to move the input forward.

The lexer works by repeatedly calling `next`, and then emitting tokens based on
what it says. The one situation where `peek` is needed is parsing names.
The lexer keeps interpreting the characters as part of the name until a
non-alpha-numeric character is reached with `peek`. 

To handle keywords, the lexer first lexes out a name, and then checks if
that name corresponds to one of the built-in keywords. This lets `printer`
lex as `Name("printer")` and not `print Name("er")`.

## Parsing
The
[parser](https://github.com/cronokirby/poline/blob/master/src/parser.rs#L219)
takes the series of tokens produced by the previous stage, and converts them
into a single representation of the program as a [syntax tree](https://github.com/cronokirby/poline/blob/master/src/parser.rs#L192).

For example, the following program:
```
fn main() {
    print "main";
    spawn main() as p;
}
```
Produces the following tree:
```
// Slightly simplified rust
Syntax {
    functions: [
        FunctionDeclaration {
            name: "main",
            arg_names: [],
            body: [
                Statement::Print(Argument::Str("main"))
                Statement::Spawn("p", FunctionCall {
                    name: "main",
                    args: []
                })
            ]
        }
    ]
}
```
This tree represents the program as presented by the user. The parsing stage
excludes programs that make no syntactic sense, e.g.
```
fn main() main() {
    print print ; ; "foo"
}
```
But it can't do anything for programs that work syntactically, but not logically.

The parser is written as a hand-crafted
[recursive descent
parser](https://en.wikipedia.org/wiki/Recursive_descent_parser),
but going into how those work is a bit outside the scope of this post.

