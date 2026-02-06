# auto_register: false
# frozen_string_literal: true

require "hanami/action"
require "dry/monads"
require "rom"

module Site
  class Action < Hanami::Action
    NotFoundError = Class.new(StandardError)

    # Provide `Success` and `Failure` for pattern matching on operation results
    include Dry::Monads[:result]

    handle_exception NotFoundError => 404
    handle_exception ROM::TupleCountMismatchError => 404

    config.formats.accept :html
  end
end
