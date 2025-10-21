---
title: dry-schema and dry-validation 1.5.0 released
date: 2020-03-11 12:00 UTC
author: Peter Solnica
---

We're happy to announce the release of dry-schema 1.5.0! It comes with plenty of new features, fixes, and general improvements. Here are some of the highlights.

## Support for composing schemas

You can now compose schemas using logical operators. The only limitation is that `xor` is not supported yet as it wasn't clear how error messages are supposed to work. This feature is experimental until we finalize it in version 2.0.0.

In the meantime, please try it out! Here's a simple example:

```ruby
RoleSchema = Dry::Schema.JSON do
  required(:id).filled(:string)
end

ExpirableSchema = Dry::Schema.JSON do
  required(:expires_on).value(:date)
end

UserSchema = Dry::Schema.JSON do
  required(:name).filled(:string)
  required(:role).hash(RoleSchema & ExpirableSchema)
end

UserSchema.(name: "Jane", role: { id: "admin", expires_on: "2020-05-01" }).errors.to_h
# {}

UserSchema.(name: "Jane", role: { id: "", expires_on: "2020-05-01" }).errors.to_h
# {role: {id: ["must be filled"]}}

UserSchema.(name: "Jane", role: { id: "admin", expires_on: "oops" }).errors.to_h
# {role: {expires_on: ["must be a date"]}}
```

[Refer to the documentation](/gems/dry-schema/1.5/advanced/composing-schemas) for more information.

## Errors about unexpected keys

Back in the dry-validation 0.x era, many people asked about returning errors for unexpected keys. Four years later, this feature is finally here! You can enable it with a simple config flag:

```ruby
UserSchema = Dry::Schema.Params do
  # Enable key validation!
  config.validate_keys = true

  required(:name).filled(:string)

  required(:address).hash do
    required(:city).filled(:string)
    required(:zipcode).filled(:string)
  end

  required(:roles).array(:hash) do
    required(:name).filled(:string)
  end
end

input = {
  foo: 'unexpected',
  name: 'Jane',
  address: { bar: 'unexpected', city: 'NYC', zipcode: '1234' },
  roles: [{ name: 'admin' }, { name: 'editor', foo: 'unexpected' }]
}

UserSchema.(input).errors.to_h
# {
#  :foo=>["is not allowed"],
#  :address=>{:bar=>["is not allowed"]},
#  :roles=>{1=>{:foo=>["is not allowed"]}}
# }
```

Notice that it works even for arrays with hashes as elements, which is **really nice**!

## Introspection extension

Another feature request that goes way back is easily seeing which keys are required and which are optional. This is now provided by a new `:info` extension, which shows both the keys and their associated types.

To enable it, you need to load the extension:

```ruby
Dry::Schema.load_extensions(:info)

UserSchema = Dry::Schema.JSON do
  required(:email).filled(:string)
  optional(:age).filled(:integer)
  optional(:address).hash do
    required(:street).filled(:string)
    required(:zipcode).filled(:string)
    required(:city).filled(:string)
  end
end

UserSchema.info
# {
#   :keys=> {
#     :email=>{
#       :required=>true,
#       :type=>"string"
#     },
#     :age=>{
#       :required=>false,
#       :type=>"integer"
#      },
#     :address=>{
#       :type=>"hash",
#       :required=>false,
#       :keys=>{
#         :street=>{
#           :required=>true,
#           :type=>"string"
#         },
#         :zipcode=>{
#           :required=>true,
#           :type=>"string"
#         },
#         :city=>{
#           :required=>true,
#           :type=>"string"
#         }
#       }
#     }
#   }
# }
```

## Summary

There's way more in the changelog so please [check it out](https://github.com/dry-rb/dry-schema/releases/tag/v1.5.0) and if you're having any issues when upgrading, please do [let us know](https://github.com/dry-rb/dry-schema/issues/new?assignees=&labels=bug&template=---bug-report.md&title=).

Big thanks go to [Rob Hanlon](https://github.com/robhanlon22) and the rest of the contributors who helped with this release!

Last but not least: dry-validation 1.5.0 was released too, which upgrades its own dependency on dry-schema to 1.5.0 and adds a couple of new features.

Please upgrade and enjoy using dry-schema and dry-validation!
