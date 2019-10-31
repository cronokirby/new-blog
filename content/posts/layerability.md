---
title: "Layerability and Abstraction"
date: 2019-10-27T17:07:40+01:00
draft: false
tags:
  - Networking
  - Programming
---

# Layerability and Networking

An interesting aspect of Networking is how different protocols are layered. For example, to view this page, you had to make
an HTTP request. That request was delivered using the TCP protocol, which in turn used the IP protocol, and finally the
underlying protocol to send data to your router (skimming a bit over details). Each of these layers only makes use of the one directly
beneath it: an implementation of an HTTP client worries about TCP, the TCP code in your OS deals with IP, etc.
This aspect is one of the best strengths of this layered model. I'll refer to this aspect as **strict layering**.

In order to make strict layering work, we need each layer to cover the needs of the layer above it. This is why some layers
have more than one protocol to choose from. For example, the application layer (HTTP et alii) can make use of either TCP or UDP.
UDP was introduced after TCP to fill some unfulfilled needs of some applications. TCP provides a reliable, ordered stream of data,
at the expense of more overhead, and (sometimes) higher latency. Some applications are willing to accept the possibility of data loss
in exchange for lower latency. For example, voice communication will rather play a snippet immediately, even if it's missing some audio,
rather than playing it later, but with complete audio. Because applications can use either TCP or UDP, depending on their constraints,
there's no urge for applications to dig further down in the networking stack. If applications sometimes needed to go underneath the transport layer abstraction,
for performance, or other reasons, then it'd break the abstraction of strict layering.

Strict layering is a stellar example of a tower of abstractions with little to no leaks. Each layer provides an interface as well
as guarantees to the layer above it. For example, TCP lets you send and receive bytes across a socket. Unlike a lower level protocol,
you can be sure that what you receive is in the right order, and isn't missing any data. Each of these layers fulfills a similar promise,
and we don't have to worry about the implementation details of everything below it.

Of course, all networking layers have an escape hatch of sorts because of the possibility of network failure:
TCP sockets can be closed without warning, and HTTP requests can sometimes fail. This is something we accept and deal with
when working with networks. Well-implemented applications do, however, provide the illusion of an infallible network. Or at least,
they provide good awareness as to what's happening.

Because each layer doesn't dig into the implementation below it, we can change the implementation while providing the same guarantees.
This allows us to improve the different layers without worrying about breaking anything. Furthermore, we can also have a higher level
protocol be adjusted to use a different underlying protocol. For example, we can switch our HTTP server for TCP to TLS in order
to have encryption. If every improvement to underlying layers required sweeping changes to all the applications above them,
those changes would simply never happen.

# Layerability and Compilers

Another good example of layerability is in compilers with different targets.

Let's take a hypothetical language, compiling to C. C in turn, is compiled down to some variant of assembly, e.g. x86-64.
This assembly language can be interpreted by different CPUs, even manufactured by different operators. There are quite
a few languages that compile to C, using this layering. C remains a popular compilation target for languages.

The compiler writer for this language only needs to understand the behavior of C, and trust in the implementation of their
C compiler. The C compiler trusts that different CPUs faithfully implement the behavior of the assembly. CPU manufacturers
faithfully provide this assembly language interface.

New languages can benefit from the existing C compilers and ecosystem, just by compiling down to C. Just as networked
applications can benefits from the work making TCP efficient, so can languages benefit from the efficiency of C compilers.

## A more leaky tower

I think that the networking stack is a stellar example of a series of abstractions without leaks, but this tower is a bit more leaky.
With the advent of modern optimizing compilers, it's difficult to beat it in writing assembly. But, there are still situations
where we need to use certain intrinsic operations present in the assembly, but not in the C language. For example, to take advantage
of vectorization operations, we need to go down to assembly, because the language doesn't give us access to these operations
directly. Of course, we could use a library making use of these primitives, and compilers are getting better at including these intrinsics.
Smart optimizing compilers will be able to find potential places to use clever assembly operations, and insert them for you.

# The key points
I think the key benefits of layerability can be summarized like this:

- The layers are reusable between different applications.
- The layers can be swapped for different behaviors.
- The layers simplify the work of the application developer.

I think we should strive for layerable architecture inside our applications, and especially
inside of the protocols we develop. This kind of layering is perhaps the only sane way to build very durable software artifacts.
