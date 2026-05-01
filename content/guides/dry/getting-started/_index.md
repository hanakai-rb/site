---
title: Overview
---

Welcome to Dry! This is a family of 20+ focused Ruby gems that help you write clear, flexible, and maintainable code. From business logic to everyday utilities, these gems work great together or standalone in any kind of app.

This guide is your map of the ecosystem. Each gem has its own guide — follow any link for a full introduction and reference.

## What Dry is about

Dry gems are:

- **Focused.** Each gem has a clear purpose, and does it well.
- **Composable.** Each gem handles a different concern, so they combine cleanly.
- **Framework-agnostic.** Works in plain Ruby, Hanami, or Rails.
- **Explicit over magic.** Clear code, no surprises.
- **Functional.** Data-oriented, with immutable values and explicit transformations.
- **Testable.** Small, focused pieces with explicit inputs make for straightforward tests.

Dry is also the foundation Hanami is built on — if you use Hanami, you're already using Dry, and are in a great position to use more of these gems.

## See Dry in action

Want to see what Dry code actually looks like? The [Dry overview](/dry) tours the headline gems with side-by-side code examples.

## Where to start

Pick a path that fits what you're building:

- **Building a full app, with Hanami, Rails, or anything else.** Start with [Dry Validation](//doc/dry/dry-validation) for inputs and [Dry Operation](//doc/dry/dry-operation) for organising processes, with [Dry Types](//doc/dry/dry-types) and [Dry Struct](//doc/dry/dry-struct) to model your domain. [Hanami](/learn/hanami) ships with these wired up and ready to use; for Rails, [Dry Rails](//doc/dry/dry-rails) is the easiest way in.
- **Writing a CLI.** [Dry CLI](//doc/dry/dry-cli) is a self-contained framework for building rich command line apps — argument parsing, subcommands, help text, and full Ruby underneath.
- **Authoring a gem.** [Dry Core](//doc/dry/dry-core), [Dry Initializer](//doc/dry/dry-initializer), and [Dry Configurable](//doc/dry/dry-configurable) cover the everyday needs of library code. [Dry Logger](//doc/dry/dry-logger) gives you structured logging without forcing it on your users.
- **Exploring functional Ruby.** [Dry Monads](//doc/dry/dry-monads) and [Dry Effects](//doc/dry/dry-effects) bring monadic composition and algebraic effects to Ruby in idiomatic ways.

## The gems

Read on for the full map of the ecosystem, grouped by what each gem helps you do.

### Validation and data

Describe the shape of your data, transform untrusted input into trusted values, and build typed objects you can rely on.

- **[Dry Validation](//doc/dry/dry-validation)** — domain validation with rule-based contracts.
- **[Dry Schema](//doc/dry/dry-schema)** — coercion and validation for data structures.
- **[Dry Types](//doc/dry/dry-types)** — an extensible type system with constraints.
- **[Dry Struct](//doc/dry/dry-struct)** — typed, immutable value objects.
- **[Dry Initializer](//doc/dry/dry-initializer)** — a params and options DSL for object initialization.
- **[Dry Logic](//doc/dry/dry-logic)** — predicate logic and composable rule objects.

### Business logic and control flow

Write explicit, testable business logic with clear paths for success and failure.

- **[Dry Operation](//doc/dry/dry-operation)** — a step-based DSL for business operations.
- **[Dry Monads](//doc/dry/dry-monads)** — monads for expressive error handling and composition.
- **[Dry Effects](//doc/dry/dry-effects)** — algebraic effects for managing side effects.

### Everyday utilities

Practical, standalone helpers for both libraries and apps.

- **[Dry Configurable](//doc/dry/dry-configurable)** — a thread-safe configuration mixin for classes.
- **[Dry Logger](//doc/dry/dry-logger)** — structured logging with pluggable formatters.
- **[Dry Inflector](//doc/dry/dry-inflector)** — string inflection and case transformation.
- **[Dry Core](//doc/dry/dry-core)** — shared utilities used across the Dry gems.
- **[Dry CLI](//doc/dry/dry-cli)** — a framework for building command line applications.
- **[Dry Files](//doc/dry/dry-files)** — a file system abstraction and utilities.

### Architecture and composition

Structure apps around clear boundaries, loosely coupled components, and explicit dependencies.

- **[Dry System](//doc/dry/dry-system)** — a dependency container with auto-registration (the basis for Hanami's [slices](//doc/hanami/app/slices)).
- **[Dry Auto Inject](//doc/dry/dry-auto_inject)** — automatic dependency injection from a container.
- **[Dry Events](//doc/dry/dry-events)** — a publish-subscribe event system.
- **[Dry Monitor](//doc/dry/dry-monitor)** — instrumentation and monitoring middleware.

### Framework integration

- **[Dry Rails](//doc/dry/dry-rails)** — a Dry-rb integration for Rails applications.

### Legacy gems

These remain for reference but are no longer recommended for new projects.

- **[Dry Container](//doc/dry/dry-container)** — now [part of Dry Core](//doc/dry/dry-core).
- **[Dry Equalizer](//doc/dry/dry-equalizer)** — now [part of Dry Core](//doc/dry-core/equalizer).
- **[Dry Matcher](//doc/dry/dry-matcher)** — superseded by [Dry Monads pattern matching](//doc/dry-monads/pattern-matching)
- **[Dry Transaction](//doc/dry/dry-transaction)** — superseded by [Dry Operation](//doc/dry/dry-operation).
- **[Dry View](//doc/dry/dry-view)** — renamed to [Hanami View](//doc/hanami/views).
