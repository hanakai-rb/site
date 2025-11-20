---
title: Introduction
pages:
  - basics:
      - built-in-predicates
      - macros
      - type-specs
      - working-with-schemas
  - optional-keys-and-values
  - nested-data
  - reusing-schemas
  - params
  - json
  - error-messages
  - advanced:
      - composing-schemas
      - custom-predicates
      - custom-types
      - filtering
      - key-maps
      - predicate-logic
      - processor-steps
      - rule-ast
      - unexpected-keys
  - extensions:
      - hints
      - info
      - json_schema
      - monads
---

`dry-schema` is a validation library for **data structures**. It ships with a set of many built-in predicates and powerful DSL to define even complex data validations with very concise syntax.

Main focus of this library is on:

- Data **structure** validation
- Value **types** validation

^INFO
`dry-schema` is used as the schema engine in [dry-validation](//doc/dry-validation) which is the recommended solution for business domain validations
^

### Unique features

There are a few features of `dry-schema` that make it unique:

- [Structural validation](//page/optional-keys-and-values) where key presence can be verified separately from values. This removes ambiguity related to "presence" validation where you don't know if value is indeed `nil` or if a key is missing in the input hash
- [Pre-coercion validation using filtering rules](//page/advanced/filtering)
- Explicit coercion logic - rather than implementing complex generic coercions, `dry-schema` uses coercion types from `dry-types` which are faster and more strict than generic coercions
- Support for [validating array elements](//page/basics/macros#array) with convenient access to error messages
- Powerful introspection - you have access to [key maps](//page/advanced/key-maps) and detailed [Rule AST](//page/advanced/rule-ast)
- Performance - multiple times faster than validations based on `ActiveModel` and `strong parameters`
- Configurable, localized error messages with or _without_ `I18n` gem

### When to use?

Always and everywhere. This is a general-purpose data validation library that can be used for many things and **it's multiple times faster** than `ActiveRecord`/`ActiveModel::Validations` _and_ `strong-parameters`.

Possible use-cases include validation of:

- Form params
- "GET" params
- JSON documents
- YAML documents
- Application configuration (ie stored in ENV)
- Replacement for `strong-parameters`
- etc.

### Quick start

```ruby
require 'dry/schema'

UserSchema = Dry::Schema.Params do
  required(:name).filled(:string)
  required(:email).filled(:string)

  required(:age).maybe(:integer)

  required(:address).hash do
    required(:street).filled(:string)
    required(:city).filled(:string)
    required(:zipcode).filled(:string)
  end
end

UserSchema.(
  name: 'Jane',
  email: 'jane@doe.org',
  address: { street: 'Street 1', city: 'NYC', zipcode: '1234' }
).inspect

# #<Dry::Schema::Result{:name=>"Jane", :email=>"jane@doe.org", :address=>{:street=>"Street 1", :city=>"NYC", :zipcode=>"1234"}} errors={:age=>["age is missing"]}>
```
