---
title: "The Component Pattern"
date: 2019-05-14T13:57:24+02:00
description: "A common architectural pattern for organising stateful code"
draft: false
---

This post details a useful pattern for organizing stateful components in functional code.
This post assumes knowledge of **Haskell**, up to **Monad-Transformers**.


## The Problem

The organization of a codebase is important: how the files are the laid out, and how
the structures inside those files mesh together. A poorly laid out codebase can be difficult
to navigate and expand. Poorly laid out code can be hard to understand, and even harder to
build upon.

A running system will be composed of different components. These components are the different
"bundles of functionality" that make up the behavior of our program. They may or may not have
analogues in the codebase itself, but a poorly organized codebase rarely makes for a well organized
set of components.

Organization is no less of a concern in *Functional Programming* than it is in the more common
forms of programming. In fact, the goals we'd like our codebase and running system to achieve
are the same for both: Modularity and Extensibility, to list a few. Even in *Haskell*, real-world
applications have stateful and effectful components to carry out the duties of a program.

There is less talk about this organizational aspect of code in the "functional literature", but it is
no less important. I think that this is because the organizational side of things is less unique or interesting
compared to other aspects of *Functional Programming*. Because of this, newcomers can learn a lot about the functional
paradigm, yet still feel unequipped to work on their own projects.


### Differences from Imperative languages

The main difference in a language like **Haskell** as compared to the more common
imperative languages, is the push towards pure functions. Pure functions are
a good organizational tool, since they make sure we don't couple functions to surrounding
state or effects. Because of this, organizing pure functions doesn't require as much care in terms
of runtime effects. Our code may be hard to understand because of its bad organization,
but it's unlikely to have far reaching side effects.

### Organising Stateful Components

Unfortunately, not all programs can be completely pure. Most programs have at least *some*
component that requires an effect of some kind, or needs to keep track of some changing state.

In *Object-Oriented* programming, the tool to segregate away effects or state is the **Class**.
In hybrid languages, like **F#** or **Scala**, using a class to organize a component like this is a perfectably
acceptable solution. In **Haskell**, however, we can't use this tool. The tools we can use are the **module** and
the **context**.

Modules allow us to organize code in a way that keeps the non-essential implementation details hidden, but the abstract
interface to that module exposed. This is similar to classes, except that the module itself has no state or effects.
A "context" allows us to write functions with access to effects or state. We can then export these functions directly from the module,
along with the details of that context, or we can hide that context, as we'll see later. **Haskell** can
implement contexts in different ways, but we'll be looking at [monad transformers](https://wiki.haskell.org/Monad_Transformers).


### The Component Pattern

Let's get into the meat of the pattern. The idea is to pair a conceptual component of a system,
say, a *logger*, for example, along with a concrete module, and effect type.

Let's use our logger example more fully. Our project needs a component
responsible for logging things to a file. We can send messages for it a log across a queue,
and it has a file that it logs to.

First we'd create a module to contain this, say `Logger.hs`:

```hs
module Logger () where
-- imports ommitted
```

The next step is to define a type that contains all the information the logger needs to run:
```hs
data LoggerInfo = LoggerInfo
    { loggerQueue :: TBQueue Message
    , loggerFile  :: FilePath
    }
```

Then we create a new effect type, which is just a Reader with access to that information:
```hs
newtype LoggerM a = LoggerM (ReaderT LoggerInfo IO a)
```

Now inside the module itself, we write the functions we need as `LoggerM a`, for example:
```hs
latestMessage :: LoggerM Message

logMessages :: LoggerM ()
```

We also have a main function that contains all the things a component needs to do, sort of like
a "main loop" for that component:
```hs
main :: LoggerM ()
```

At this point we have the tools to express functions for that component inside the module itself,
but no API to interact with the component from outside. We have 2 options for exposing this
component to the outside world.

- Export `LoggerInfo` and `LoggerM`, as well as `main`

We'd have functions to construct `LoggerInfo` as well as run `LoggerM`:

```hs
makeLoggerInfo :: File -> IO LoggerInfo

runLoggerM :: LoggerM a -> LoggerInfo -> IO a
```

- Completely hide the existence of `LoggerInfo` and `LoggerM`

With this choice, we'd only export a function that constructs and runs the main logger computation:

```hs
runLoggerMain :: File -> IO ()
```

Regardless of which choice we make, we're free to start the logger component in a new thread if we want.
This is usually done, because components generally contain independent pieces of state, and spend all their time
doing the same thing over and over, rather than acting as a one time task.

Hiding everything is the preferred choice, as it provides more encapsulation, and a cleaner API.
Users of the component can ignore the implementation details of the component completely, and just run a single
function in a new thread after passing it all the prerequisite information.


## Summary
In summary, the component pattern looks something like this:

```hs
module Component (startComponent) where

data ComponentInfo

newtype ComponentM a = ComponentM (ReaderT ComponentInfo IO a)

main :: ComponentM ()

startComponent :: Dependencies -> IO ()
```

This isn't the end-all-be-all of organising stateful components of a larger project,
but hopefully this is a useful pattern to put in the toolbox :)

## Further Reading
- https://www.fpcomplete.com/blog/2017/06/readert-design-pattern

