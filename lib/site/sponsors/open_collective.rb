# frozen_string_literal: true

require "date"
require "json"
require "net/http"
require "time"
require "uri"

module Site
  module Sponsors
    # Reads the current backers of an Open Collective account.
    #
    # A backer counts as a current sponsor when they have an active recurring order, or when they
    # made a one-off donation inside the given window.
    #
    # Donors who gave anonymously are never named. Open Collective reports `isIncognito` as false
    # for them, so we go by the account slug instead: incognito and guest donors get generated
    # slugs with a known prefix.
    class OpenCollective
      ENDPOINT = URI("https://api.opencollective.com/graphql/v2")

      ORDER_LIMIT = 500

      QUERY = <<~GRAPHQL
        query($slug: String!, $limit: Int!) {
          account(slug: $slug) {
            orders(filter: INCOMING, status: [ACTIVE, PAID], limit: $limit) {
              totalCount
              nodes {
                createdAt
                frequency
                status
                fromAccount { slug name imageUrl(height: 96) }
              }
            }
          }
        }
      GRAPHQL

      SOURCE = "open_collective"

      ANONYMOUS_SLUG_PREFIXES = %w[guest- incognito-].freeze

      def initialize(slug:, one_time_window_months:, token: nil, now: Time.now)
        @slug = slug
        @token = token
        @one_time_window_months = one_time_window_months
        @now = now
      end

      def call
        named, anonymous = current_orders
          .map { it.fetch("fromAccount") }
          .uniq { it.fetch("slug") }
          .partition { !anonymous?(it) }

        Listing.new(sponsors: named.map { named_sponsor(it) }, private_count: anonymous.length)
      end

      private

      def current_orders
        orders = request.fetch("account").fetch("orders")

        if orders.fetch("totalCount") > ORDER_LIMIT
          raise "#{@slug} has more than #{ORDER_LIMIT} orders; add paging to #{self.class}"
        end

        orders.fetch("nodes").select { current?(it) }
      end

      def current?(order)
        if order.fetch("frequency") == "ONETIME"
          order.fetch("status") == "PAID" && Time.parse(order.fetch("createdAt")) >= one_time_cutoff
        else
          order.fetch("status") == "ACTIVE"
        end
      end

      def one_time_cutoff
        @one_time_cutoff ||= (@now.to_date << @one_time_window_months).to_time
      end

      def anonymous?(account)
        ANONYMOUS_SLUG_PREFIXES.any? { account.fetch("slug").start_with?(it) }
      end

      def named_sponsor(account)
        slug = account.fetch("slug")

        {
          "source" => SOURCE,
          "name" => account["name"].to_s.empty? ? slug : account.fetch("name"),
          "handle" => slug,
          "profile_url" => "https://opencollective.com/#{slug}",
          "avatar_url" => account.fetch("imageUrl")
        }
      end

      def request
        headers = {
          "Content-Type" => "application/json",
          "User-Agent" => "hanakai-site-sponsors"
        }
        # Public collective data needs no token. One only raises our rate limit.
        headers["Personal-Token"] = @token if @token

        response = Net::HTTP.post(
          ENDPOINT,
          JSON.generate(query: QUERY, variables: {slug: @slug, limit: ORDER_LIMIT}),
          **headers
        )

        unless response.is_a?(Net::HTTPSuccess)
          raise "Open Collective API returned #{response.code}: #{response.body}"
        end

        body = JSON.parse(response.body)

        if body["errors"]
          raise "Open Collective API returned errors: #{body["errors"].map { it["message"] }.join("; ")}"
        end

        body.fetch("data")
      end
    end
  end
end
