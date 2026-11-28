---
title: Virtus Legacy
---

Dry Struct is a successor of earlier project called [Virtus](https://github.com/solnic/virtus). Virtus gained relative popularity in Ruby world with 3.7k stars on Github and over 125M downloads on RubyGems (stats for April 2026). It was officially discontinued in 2021 in favor of Dry ecosystem.

### Differences between Dry Struct and Virtus

Dry Struct` look somewhat similar to Virtus but there are few significant differences:

- Structs don't provide attribute writers and are meant to be used as "data objects" exclusively
- Handling of attribute values is provided by standalone type objects from `dry-types`, which gives you way more powerful features
- Handling of attribute hashes is provided by standalone hash schemas from `dry-types`, which means there are different types of constructors in `dry-struct`
- Structs are not designed as swiss-army knives, specific constructor types are used depending on the use case
- Struct classes quack like `dry-types`, which means you can use them in hash schemas, as array members or sum them
