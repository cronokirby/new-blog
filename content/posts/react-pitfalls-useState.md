---
title: "React Pitfalls: useState initialization"
date: 2020-01-09T10:10:11+01:00
draft: false
description: "A common pitfall in React is to initialize useState with a dynamic value, this leads to a bunch of weird bugs"
tags:
  - "React"
  - "Hooks"
  - "Frontend"
  - "Javascript"
---

# Summary

This is a quick post about a "gotcha" I encountered recently in a React application.
This involved the use of React's `useState` hook, which had a subtle difference
between how I thought the hook worked, and how it actually worked.

# React Hooks

If you're already familiar with hooks in React, feel free to skip this section. This
is just a recap for those out of the loop.

Although the first real framework I worked with was _Vue_ (I don't count the one application
I built with JQuery as having used a framework), I've been using _React_ a ton lately, and
it's really been growing on me. There's a lot of advantages to being the "top dog" in the
framework game, and React's popularity gives you access to a large ecosystem, and great
patterns for working on frontend applications.

One thing I really like about React is the recent "hooks" feature.

Previously, react distinguished between _function_ components, which took in some parameters,
called _props_, and returned some HTML to be rendered, e.g.

```
function TitleCard({ name }) {
  return <p>Hi my name is {name}</p>;
}
```

You also had _class_ components, which at first resemble _function_ components:

```
class TitleCard extends React.Component {
  render() {
    return <p>Hi my name is {this.props.name}</p>;
  }
}
```

But class components also have a lot of other features in addition to just rendering some data.
Notably, they have access to state:

```
class Counter extends React.Component {
  constructor(props) {
    super(props);
    this.state = {count: 0};
  }

  render() {
    return (
      <div>
        <p>{this.state.count}</p>
        <button onClick={() => this.state.count++}>+</button>
      </div>
    );
  }
}
```

This component will render a count, and clicking on the button inside that component will increment
the state of that component.

Having a clear way to use state, and other effects like network requests, etc was something missing
from function components. That's where hooks come in. Hooks, in brief, allow you to use
these things in function components.

For example, if we wanted to take our `Counter` component from the previous example
using a function component with hooks, it'd look like this:

```
function Counter() {
  const [count, setCount] = React.useState(0);
  return (
    <div>
      <p>{count}</p>
      <button onClick={() => setCount(c => c + 1)}>+</button>
    </div>
  );
}
```

The hook provides us with two values: `count`, and `setCount`. The idea is that
`count` always holds the current value of the state, and `setCount` allows us to change
this value. The cool thing is that React will always "do the right thing" and magically
update this value and rerender the component if necessary. Neat!

# Rerendering

One of the core principles when working with React is that the framework strives
to make sure that the values a component logically has is always reflected on screen.
This means that if some value changes, because of a hook, or because one of the props changed,
then a rerender needs to happen to make sure that what's on screen matches what's "in the code".

For example, let's split our counter in two:

```
function ShowCounter({ count, setCount }) {
  return (
    <div>
      <p>{count}</p>
      <button onClick={() => setCount(c => c + 1)}>+</button>
    </div>
  );
}

function Counter() {
  const [count, setCount] = React.useState(0);
  return <ShowCounter {...{count, setCount}}/>
}
```

Now the `Counter` component is the one actually holding the state, and the `ShowCounter` component
is just a simple function that shows the data given to it. In order to make sure that the user is
always seeing the actual value of the counter, React has to rerender the `ShowCounter` component
whenever the count passed to it changes value.

This means that React will end up executing the code of the `ShowCounter` function again. This
is why its important to avoid firing off network requests without `useEffect` inside
a function component, because you only want to do certain effects when they need to be run,
and not just when the component frivously rerenders.

# State is initialised only once

Now we come to the main pitfall I want to talk about in this post.

Let's allow the user set a value for the counter:

```
function Counter({ initial }) {
  const [count, setCount] = React.useState(initial);
  return <ShowCounter {...{count, setCount}}>;
}
```

Based on our previous model, if `initial` changes, then the component has to rerender,
and so `useState` gets called with `initial`, and so the count becomes `initial`, right?

Well it turns out that that's not what happens. In fact with the way `useState` works,
the initial value matters only **the first time a component renders**. After that, it will
preserve the state between renders.

This means that we need to do this instead:

```
function Counter({ initial }) {
  const [count, setCount] = React.useState(0);
  React.useEffect(() => setCount(initial), [initial]);
  return <ShowCounter {...{count, setCount}}>;
}
```

We haven't gone over the `useEffect` hook in detail, but the way it works is that it executes
the callback function only if the values inside the array have changed. So here it will set the counter
to an initial value, but only when the initial value changes. This is the correct way to do
something like this.

Basically, to avoid this pitfall, **you never want to have anything dynamic inside the call to useState**.

# Why is this the case?

Well, remember how we went over how React "tries to do the right thing". Well, it turns out that
by doing things this way, you actually preserve state between rerenders, which is generally the behavior you want.

For example, let's say we had something like this:

```
function Counter({ name }) {
  const [count, setCount] = React.useState(0);
  return (
    <div>
      <p>{name}</p>
      <p>{count}</p>
      <button onClick={() => setCount(c => c + 1)}>+</button>
    </div>
  );
}
```

Now we're showing a name in addition to the value of the count. We want to rerender if the count or the name
changes, since we want the user to see what the current value actually is, but we don't want the count to be
lost just because the name changed. That's why it makes sense for `useState` to preserve the
state between rerenders.

It'd require a lot more code to create the behavior of preserving state between rerenders if
it didn't work that way, but it didn't take much effort with `useEffect` to do what we wanted
in the other case. You generally want to try and make the more common use case easy
with frameworks, don't you.

## Further Reading

[React Hooks](https://reactjs.org/docs/hooks-intro.html)
