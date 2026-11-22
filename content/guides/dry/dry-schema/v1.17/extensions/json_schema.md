---
title: JSON Schema
---

The `:json_schema` extension allows you to generate a valid [JSON Schema](https://json-schema.org/) from a `Dry::Schema`. JSON Schema is a widely used standard, so this unlocks many possibilities.

```ruby
Dry::Schema.load_extensions(:json_schema)

UserSchema = Dry::Schema.JSON do
  required(:email).filled(:str?, min_size: 8)
  optional(:favorite_color).filled(:str?, included_in: %w[red green blue pink])
  optional(:age).filled(:int?)
end

UserSchema.json_schema
# {
#   "type": "object",
#   "properties": {
#     "email": {
#       "type": "string",
#       "minLength": 8
#     },
#     "favorite_color": {
#       "type": "string",
# .     "enum": ["red", "green", "blue", "pink"]
#     },
#     "age": {
#       "type": "integer"
#     },
#   },
#   "required": ["email"]
# }
```

### Converting predicates

The extension converts each predicate in your schema to its matching JSON Schema keywords:

| Predicates                                          | JSON Schema                                                  |
| --------------------------------------------------- | ------------------------------------------------------------ |
| Type predicates, such as `str?`, `int?` and `bool?` | `type` (plus `format` for `date?`, `date_time?` and `time?`) |
| `filled?`                                           | `minLength: 1` for strings                                   |
| `min_size?`, `max_size?`                            | `minLength`, `maxLength` (`minItems`, `maxItems` for arrays) |
| `size?`                                             | `minLength` and `maxLength`, both set to the given size      |
| `format?`                                           | `pattern`                                                    |
| `eql?`                                              | `const`                                                      |
| `included_in?`                                      | `enum`                                                       |
| `gt?`, `gteq?`, `lt?`, `lteq?`                      | `exclusiveMinimum`, `minimum`, `exclusiveMaximum`, `maximum` |
| `odd?`, `even?`                                     | `multipleOf`                                                 |
| `uuid_v1?` to `uuid_v8?`                            | `pattern`                                                    |
| `true?`, `false?`                                   | `type: "boolean"` only                                       |

For example:

```ruby
Dry::Schema.load_extensions(:json_schema)

SignupSchema = Dry::Schema.JSON do
  required(:code).filled(:string, size: 6, format: /^[A-Z]+$/)
  required(:tags).value(:array, min_size: 1, max_size: 5)
  required(:terms).value(:bool, :true?)
  required(:version).value(:integer, eql: 1)
end

SignupSchema.json_schema
# {
#   "$schema": "http://json-schema.org/draft-06/schema#",
#   "type": "object",
#   "properties": {
#     "code": {
#       "type": "string",
#       "minLength": 6,
#       "maxLength": 6,
#       "pattern": "^[A-Z]+$"
#     },
#     "tags": {
#       "type": "array",
#       "minItems": 1,
#       "maxItems": 5
#     },
#     "terms": {
#       "type": "boolean"
#     },
#     "version": {
#       "type": "integer",
#       "const": 1
#     }
#   },
#   "required": ["code", "tags", "terms", "version"]
# }
```

The `format?` predicate uses your regular expression's source as the `pattern`. JSON Schema patterns use JavaScript regular expression syntax, so prefer `^` and `$` over Ruby-only anchors such as `\A` and `\z`.

### Loose mode

If your schema uses a predicate that has no JSON Schema equivalent, such as `excluded_from?`, `json_schema` raises a `Dry::Schema::JSONSchema::SchemaCompiler::UnknownConversionError`. This makes sure the JSON Schema does not quietly leave out one of your validations.

To skip these predicates instead, generate the schema in loose mode:

```ruby
UserSchema.json_schema(loose: true)
```

### Learn more

- [Official JSON Schema docs](https://json-schema.org/)
- [Auto-generate forms with React + JSON Schema](https://github.com/rjsf-team/react-jsonschema-form))
- [Integrate with other languages more easily](https://json-schema.org/implementations.html)
