# frozen_string_literal: true

require "dry/types"

module Site
  Types = Dry.Types(default: :strict)

  module Types
    PageNumber = Params::Integer.constrained(gt: 0).fallback(1)
  end
end
