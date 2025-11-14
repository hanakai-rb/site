---
title: Number Formatting
---

Hanami offers a helpful way to present numbers via `#format_number` helper method. It returns a formatted string for the given number.

- If an integer is given, applies no precision in the returned string.
- For all other kinds (`Float`, `BigDecimal`, etc.), formats the number as a float.

## Usage

Here is how you can use it in templates:

    <span><%= format_number(1_000_000) %></span>
    <span><%= format_number(1_000_000.10) %></span>

This will render the number in the nice, readable form:

    <span>1,000,000</span>
      <span>1,000,000.00</span>

[In parts](/v2.3/views/parts), you can access your helpers via the `helpers` object.

Given you have a view exposure defined:

    # app/views/books/show.rb

    module Bookshelf
      module Views
        module Books
          class Index < Bookshelf::View
            expose :books do
              [
                Book.new(title: "Hanami")
                Book.new(title: "Hanami 2")
              ]
            end
          end
        end
      end
    end

Then you can have the part with the helper used.

    # app/views/parts/books.rb

    module Bookshelf
      module Views
        module Parts
          module Books
            def formatted_count
              helpers.format_number(value.count)
            end
          end
        end
      end
    end

Then in the template you can just access the part:

    # app/templates/books/index.html.erb

    <%= books.formatted_count %>

    <span>1,000,000</span>

## Precision

The default precision is of `2`, but we can specify a different value with the homonym option.

    format_number(Math::PI) # => "3.14"
    format_number(Math::PI, precision: 6) # => "3.141592"

## Delimiter

The default thousands delimiter is `,`. We can use `:delimiter` for a different char.

    format_number(1_000_000) # => "1,000,000"
    format_number(1_000_000, delimiter: '.') # => "1.000.000"

## Separator

The default separator is `.`. We can use `:separator` for a different char.

    format_number(1.23) # => "1.23"
    format_number(1.23, separator: ',') # => "1,23"

