---
title: "From Interfaces to Traits"
date: 2019-08-17T08:32:00-04:00
draft: true
---

This is a post about how different languages
handle the concept of **interfaces**. We'll go over the classical
*OO* way of handling them, with *Java*, to the more recent
approaches of languages like *Rust*, as well as others in between.

# Why do we want interfaces?
The problem **interfaces** address is *polymorphism*.
*Polymorphism* is the ability for code to be flexible, and work
on different types of things. In practice this means functions
that can accept different types, and work differently based on those
types.

For example, we might have a function that can do arithmetic
on integers as well as floating point numbers.

# Classical Interfaces
**Interfaces** in *Java* are a variant of *inheritance*, so
let's look over how that works in *Java* first.

## Inheritance
*Java* has *classes*, and these have *methods*.
For example:
```java
class Rectangle {
  private int height;
  private int width; 
  
  public Rectangle(height, width) {
    this.height = height;
    this.width = width;
  }
  
  public int area() {
    return height * width;
  }
}
```
This is a class, with two *fields*, a *constructor*, and a *method*
that makes use of both of those fields.

We can create a new *instance* of this *class*, and call its methods
as follows:
```java
var rectangle = new Rectangle(3, 4);
System.out.println(rectangle.area());
```
This program prints out `12`, as expected.

We can also make new *classes* which inherit from another one,
for example:
```java
class Square extends Rectangle {
  public Square(width) {
    super(width, width);
  }
}
```

This *class* can be used like this:
```java
var square = new Square(3);
System.out.println(square.area());
```
This program prints out `9`.

The `Square` *class* inherits all the methods and their implementations
from its parent class `Rectangle`, and can use its parent's constructor.

*Classes* can also change the implementation of certain methods. This
is called *overriding* in *Java*.

```java
  @Override
  public int height() {
    // new behavior
  }
```

## Abstract Classes
*Java* also has a feature called *abstract classes*.

*Abstract Classes* have one big difference from normal classes:
they can choose to not provide an implementation for a given method.

For example:
```java
abstract class Shape {
  abstract int height();
  
  int heightSquared() {
    var h = height();
    return h * h;
  }
}
```
We've left the `height` method *abstract*. We can't actually create
instances of the `Shape` class. Instead, we need to extend the *class*,
with another, and then we can create instances of that *subclass*.

## Interfaces
Now that we've seen *classes*, and then *abstract classes*, we
can move on to *interfaces*, as implemented in *Java*.

An *interface* is essentially an *abstract class*, where
all the methods are *abstract*.

For example:
```java
interface ShapeLike {
  int area();
}
```

We can then have different *classes* that implement this interface:

```java
class Rectangle implements ShapeLike {
  int area() {
    return width * height;
  }
}

class Square implements ShapeLike {
  int area() {
    return width * width;
  }
}
```

This can be used for polymorphism, by declaring a function that accepts
an interface instead of a specific type:

```java
class ShapeUtils {
   static int areaSquared(ShapeLike shape) {
     var a = shape.area();
     return a * a;
   }
}
```
(We make a *class* with a *static* method because *Java* doesn't like free functions).

One key thing to notice here is that each *class* has to explicitly
declare that it implements a given *interface*. There's no way to make
an old *class* implement a new *interface*.

*Java* has many other ways of implementing *polymorphism* through
inheritence, from *subclassing* to *abstract classes* to *interfaces*.
All of these have the common characteristic of a function accepting a given
type, and not knowing whether or not that argument is of that type exactly,
or a given subtype. When accepting an *interface*, a function can only use
the methods that *interface* provides, and is oblivious to the other details the
various *classes* implementing that *interface* provide.

# Middle Ground: Go
The main different between *Go* and *Java* is that in *Go*, implementing
an *interface* is implicit, whereas in *Java*, this is explicit.

Continuing with our geometry examples, in *Go* we might have code
that looks like this:
```go
package main

import "fmt"

type Shape interface {
  area() int
}

type Square struct {
  width int
}

func (s Square) area() int {
  return s.width * s.width
}

func main() {
  var s Shape
  s = Square{width: 3}
  fmt.Println(s.area())
}
```
(This is actually a complete *Go* program that can be run, and prints out `9`)

The first part of this program declares a new *interface* type, named `Shape`.
This *interface* is defined by the method `area`. With the way *interfaces*
work in *Go*, any type that has a method named `area` with the right type signature
can be used as that *interface*. Later on in the program, we assign a value
of type `Square` to a variable of type `Shape`. This is allowed because
`Square` has a method with the right name and types.

