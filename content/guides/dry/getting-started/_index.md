---
title: Overview
---

Welcome to Dry! This is a family of 20+ small, focused Ruby gems that help you write clear, flexible, and maintainable code. From business logic to everyday utilities, these gems work great together or standalone in any kind of app.

This guide is your map of the ecosystem. Each gem has its own guide — follow any link for a full introduction and reference.

## What Dry is about

- **Small and focused.** Each gem does one thing well. Use what you need, skip what you don't.
- **Framework-agnostic.** Dry works equally well in plain Ruby, in a Hanami app, or alongside Rails.
- **Explicit over magic.** Clear, obvious code over implicit behaviour.
- **Proven in production.** Built on more than a decade of real-world use and refinement.

Dry is also the foundation on which Hanami is built — if you use Hanami, you're already using Dry.

## Validation and data

Describe the shape of your data, transform untrusted input into trusted values, and build typed objects you can rely on.

- **[Dry Validation](//doc/dry/dry-validation)** — domain validation with rule-based contracts.
- **[Dry Schema](//doc/dry/dry-schema)** — coercion and validation for data structures.
- **[Dry Types](//doc/dry/dry-types)** — an extensible type system with constraints.
- **[Dry Struct](//doc/dry/dry-struct)** — typed, immutable value objects.
- **[Dry Initializer](//doc/dry/dry-initializer)** — a params and options DSL for object initialization.
- **[Dry Logic](//doc/dry/dry-logic)** — predicate logic and composable rule objects.

## Business logic and control flow

Write explicit, testable business logic with clear paths for success and failure.

- **[Dry Operation](//doc/dry/dry-operation)** — a step-based DSL for business operations.
- **[Dry Monads](//doc/dry/dry-monads)** — monads for expressive error handling and composition.
- **[Dry Effects](//doc/dry/dry-effects)** — algebraic effects for managing side effects.

## Everyday utilities

Practical, standalone helpers for both libraries and apps.

- **[Dry Configurable](//doc/dry/dry-configurable)** — a thread-safe configuration mixin for classes.
- **[Dry Logger](//doc/dry/dry-logger)** — structured logging with pluggable formatters.
- **[Dry Inflector](//doc/dry/dry-inflector)** — string inflection and case transformation.
- **[Dry Core](//doc/dry/dry-core)** — shared utilities used across the Dry gems.
- **[Dry CLI](//doc/dry/dry-cli)** — a framework for building command line applications.
- **[Dry Files](//doc/dry/dry-files)** — a file system abstraction and utilities.

## Architecture and composition

Structure apps around clear boundaries, loosely coupled components, and explicit dependencies.

- **[Dry System](//doc/dry/dry-system)** — a dependency container with auto-registration (the basis for Hanami's [slices](//doc/hanami/app/slices)).
- **[Dry Auto Inject](//doc/dry/dry-auto_inject)** — automatic dependency injection from a container.
- **[Dry Events](//doc/dry/dry-events)** — a publish-subscribe event system.
- **[Dry Monitor](//doc/dry/dry-monitor)** — instrumentation and monitoring middleware.

## Framework integration

- **[Dry Rails](//doc/dry/dry-rails)** — a Dry-rb integration for Rails applications.

## Legacy gems

Three Dry gems remain here for reference but are no longer recommended for new projects.

- **[Dry Container](//doc/dry/dry-container)** — now [part of Dry Core](//doc/dry/dry-core).
- **[Dry Equalizer](//doc/dry/dry-equalizer)** — now [part of Dry Core](//doc/dry-core/equalizer).
- **[Dry Matcher](//doc/dry/dry-matcher)** — superseded by [Dry Monads pattern matching](//doc/dry-monads/pattern-matching)
- **[Dry Transaction](//doc/dry/dry-transaction)** — superseded by [Dry Operation](//doc/dry/dry-operation).
- **[Dry View](//doc/dry/dry-view)** — renamed to [Hanami View](//doc/hanami/views).

## Where to next

New to Dry? Start with whichever gem solves a problem you have right now. If you're validating input, try [Dry Validation](//doc/dry/dry-validation). If you're organising business logic, try [Dry Operation](//doc/dry/dry-operation). If you're modelling your domain, try [Dry Types](//doc/dry/dry-types) and [Dry Struct](//doc/dry/dry-struct).

Want to see Dry gems already wired together in a full app? Check out [Hanami](/learn/hanami) — it's built on Dry from the ground up, with everything set up and ready to use.

Otherwise, use the sidebar to jump straight into any gem's guide.
