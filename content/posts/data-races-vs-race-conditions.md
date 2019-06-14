---
title: "Data Races vs Race Conditions"
date: 2019-06-14T20:15:10+02:00
draft: true
---

This is a quick post about the difference between `Data Races` and
`Race Conditions`, and how data structures or patterns providing freedom
from data races can fail to provide race condition freedom.

The examples will be given in `Go`, since that's a language with a few
of the concurrent constructs that come into play here, as well as the language
that sparked this blog post in the first place.

## Data Races

I agree almost entirely with
[rust's definition of data races](https://doc.rust-lang.org/nomicon/races.html).
Under this definition, a data race is when one or more thread concurrently
access a location in memory / variable, at least one of which is a write,
and at least one of which is not synchronized with other threads.

For example, multiple concurrent reads to an unsychronized variable are perfectly
fine:
```go
const a = 3

func main() {
    go func() {
        fmt.Printf("Thread B: %d\n", a)
    }
    fmt.Printf("Thread A: %d\n", a)
}
```
Even though the order of printing will vary from execution to execution,
there are no data races since both threads are merely reading from the data.

If we now have one of the threads access `a` mutably, we introduce a data race:
```go
func main() {
    a := 3
    go func() {
        a = 10
    }
    fmt.Printf("Thread A: %d\n", a)
}
```

We can solve this by introducing a mutex to synchronize access to `a`:
```go
func main() {
    a := 3
    var m sync.Mutex
    go func() {
        m.Lock()
        a = 10
        m.Unlock()
    }
    m.Lock()
    fmt.Printf("Thread A: %d\n", a)
    m.Unlock()
}
```
Both threads are accessing `a` at the same time, and one of them is writing,
but since the access is synchronized, this is no longer a data race.

## Race Conditions

Race conditions stem from `non-determinism` in concurrent programs.
In theory any observable non-determinsm from concurrency could be *considered*
a race condition, but in practice what constitutes a race condition depends
on what properties we want our program to respect.
