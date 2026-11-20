---
title: Extensions
---

Extensions add optional features to your operations. Each extension depends on another gem, which you must add to your app yourself. To use an extension, require it and include it in your operation class.

## Validation

- [Validation](//page/extensions/validation): validates your operation's input with Dry Validation before the operation runs.

## Database transactions

These extensions wrap steps in a database transaction, and roll back the transaction if any step returns a `Failure`:

- [ROM](//page/extensions/rom)
- [Sequel](//page/extensions/sequel)
- [ActiveRecord](//page/extensions/active-record)
