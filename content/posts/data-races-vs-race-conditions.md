---
title: "Data Races vs Race Conditions"
date: 2019-06-14T20:15:10+02:00
draft: false
tags:
  - Concurrency
  - Go
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
Under this definition, a data race is when one or more threads concurrently
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
In theory any observable non-determinism from concurrency could be *considered*
a race condition, but in practice what constitutes a race condition depends
on what properties we want our program to respect.

Let's take the following program as an example:
```go
func main() {
    go func() {
        for {
            fmt.Println("Thread B")
        }
    }
    for {
        fmt.Println("Thread A")
    }
}
```
We'll see some sort of random interleaving of the two messages:
```
Thread A
Thread A
Thread B
Thread A
Thread B
Thread B
...
```
This could be considered a race condition, if the exact order of the printing
was a property we wanted our program to respect. We could use some form of
synchronization to enforce that order of printing.

In practice we wouldn't consider this a race condition even if the execution
isn't deterministic, because this isn't a property we care about.

In summary, a race condition is some violation of the properties our program
should have arising from the concurrent execution of the program.

## Race Conditions without Data Races

The reason I decided to make this post was a discussion I had recently.
Someone was claiming that using Go's channels prevents *race conditions*
because the operations are always thread safe.

It is true that Go's channels are free from *data races*, so long as memory
isn't shared in other ways. That being, said it's pretty easy to
write a program that has a race condition despite only using channels.

In this example, we'll have a simple server responding to requests to get
the value of an integer, and to set the value of an integer.

The messages look like this:
```go
type msg struct {
    id int
    amount int
}
```
We'll use `0` as the id for `get` and `1` as the id for `set`.

Our server type will look like this:
```go
type server struct {
  msgs chan msg
  resps chan int
}

func newServer() *server {
  msgs := make(chan msg)
  resps := make(chan int)
  return &server{msgs, resps}
}
```

We have a channel to be able to send and receive messages for the server,
as well as a channel for the responses to those messages.

Our server will start in the background with the following function:
```go
func (s *server) start() {
  state := 0
  for {
    m := <-s.msgs;
    if m.id == 0 {
      s.resps <- state
    } else {
      state = m.amount
    }
  }
}
```
We respond to get requests by sending back the current state, and to set requests
by setting the concurrent state. Since only one thread is in control
of the state, interactions with the server are free from data races.

The basic operations with our server look like this:
```go
func (s *server) get() int {
  s.msgs <- msg{0, 0}
  return <-s.resps
}

func (s *server) set(amount int) {
  s.msgs <- msg{1, amount}
}
```

Now with those basic operations, we can define the following function:
```go
func (s *server) increment() {
  x := s.get()
  s.set(x + 1)
}
```
This function simply increments the state.

In our main function, we can do the following:
```go
func main() {
  s := newServer()
  go s.start()
  for i := 0; i < 200; i++ {
      s.increment()
  }
  fmt.Println(s.get())
}
```
This will perform 200 increment operations, leaving the state at 200, as expected.

But if we start sharing these operations between threads, we'll notice
a race condition:
```go
func main() {
  s := newServer()
  go s.start()
  go func() {
      for i := 0; i < 100; i++ {
          s.increment()
      }
  }
  for i := 0; i < 100; i++ {
      s.increment()
  }
  fmt.Println(s.get())
}
```
We would expect to see 200, as before, but in practice we'll see a smaller number.
This is a race condition. This happens because 2 threads can get the same value
before setting the next one, and then both will set the same value, leading
to 2 calls to increment only performing a single increment.

## Simple fixes are not enough
What we want is an *atomic operation*. In this case an atomic increment.
An atomic increment would mean that each increment happens as a single step,
and thus prevent two concurrent increments from only leading to a single
operation.

We could add such an operation to our server with an additional message,
let's say with id `2`:
```go
else if m.id == 2 {
    state++
}
```

The problem is that the following function still wouldn't be atomic:
```go
func (s *server) doubleIncrement() {
    s.increment()
    s.increment()
}
```

No matter what set of atomic operations our server provides for its state,
we can't simply perform multiple operations in sequence, in an unsynchronized
manner, and expect the result to also be atomic.

The full code for this example can be found here:
https://play.golang.org/p/995MLEiqIVV

## Summary

Data races should not be conflated with race conditions. Just because
a data structure provides data race free operations, doesn't mean that race conditions
can't happen with that data structure. Furthermore, sequencing
atomic operations does not yield an atomic operations.

Designing concurrent programs without bugs is not trivial, and becomes
even more complicated once you start working with multiple computers.
