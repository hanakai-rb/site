# frozen_string_literal: true

module Site
  module Sponsors
    # The sponsors of one platform: the ones we can name, plus a count of the ones we cannot.
    #
    # Private sponsors are only ever a number. We do not read their names, so there is nothing to
    # carry around for them.
    Listing = Data.define(:sponsors, :private_count)
  end
end
