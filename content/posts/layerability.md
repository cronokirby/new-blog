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
underlying protocol to send data to your router (skimming a bit over details). Each layer only makes use of the layer directly
beneath it: an implementation of an HTTP client worries about TCP, the TCP code in your OS deals with IP, etc. I'll refer
to each layer using only the next as **strict layering**.

In order to make strict layering work, we need each layer to cover the needs of the layer above it. This is why some layers
have more than one protocol to choose from. For example, the application layer (HTTP et alii) can make use of other TCP or UDP.
UDP was introduced after TCP to fill some unfulfilled needs of some applications. TCP provides a reliable, ordered stream of data,
at the expense of more overhead, and (sometimes) higher latency. Some applications are willing to accept the possibility of data loss
in exchange for lower latency. For example, voice communication will rather play a snippet immediately, even if it's missing some audio,
rather than playing it later, but with complete audio. If applications sometimes needed to go underneath the transport layer abstraction,
for performance, or other reasons, then it'd break the abstraction of strict layering.

Strict layering is a stellar example of a tower of abstractions with little to no leaks. Each layer provides an interface as well
as guarantees to the layer above it. When TCP says that it provides you an ordered byte stream, you can bet that the bytes you receive
are in the same order as they were sent. Of course, all networking layers have an escape hatch of sorts because of the possibility
of network failure. TCP sockets can be closed without warning, and HTTP requests can sometimes fail.

Because each layer doesn't dig into the implementation below it, we can change the implementation while providing the same guarantees.
This allows us to improve the different layers without worrying about breaking anything. Furthermore, we can also have a higher level
protocol be adjusted to use a different underlying protocol. For example, we can switch our HTTP server for TCP to TLS in order
to have encryption.

# Layerability and Compilers

Another good example of layerability is in compilers with different targets.
