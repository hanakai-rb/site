# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Site
  module Sponsors
    # Reads the current sponsors of a GitHub Sponsors account.
    #
    # Sponsors who chose to stay private are never named. They come back as anonymous entries.
    #
    # Note that we deliberately avoid the `sponsors` connection on the GraphQL API. It names private
    # sponsors when the token belongs to an admin of the sponsored account, so using it would leak
    # names onto the site.
    class GitHub
      ENDPOINT = URI("https://api.github.com/graphql")

      # The GraphQL API returns at most 100 nodes per page. We ask for one page and raise if there
      # are more, rather than quietly dropping sponsors off the end of the list.
      PAGE_LIMIT = 100

      QUERY = <<~GRAPHQL
        query($login: String!, $limit: Int!) {
          organization(login: $login) {
            publicSponsorships: sponsorshipsAsMaintainer(first: $limit, includePrivate: false, activeOnly: true) {
              totalCount
              nodes {
                sponsorEntity {
                  __typename
                  ... on User { login name avatarUrl(size: 96) }
                  ... on Organization { login name avatarUrl(size: 96) }
                }
              }
            }
            allSponsorships: sponsorshipsAsMaintainer(includePrivate: true, activeOnly: true) {
              totalCount
            }
          }
        }
      GRAPHQL

      SOURCE = "github"

      def initialize(login:, token:)
        @login = login
        @token = token
      end

      def call
        organization = request.fetch("organization")
        public_sponsorships = organization.fetch("publicSponsorships")
        total = organization.fetch("allSponsorships").fetch("totalCount")

        if public_sponsorships.fetch("totalCount") > PAGE_LIMIT
          raise "#{@login} has more than #{PAGE_LIMIT} public sponsors; add paging to #{self.class}"
        end

        named = public_sponsorships.fetch("nodes").map { named_sponsor(it.fetch("sponsorEntity")) }

        Listing.new(sponsors: named, private_count: [total - named.length, 0].max)
      end

      private

      def named_sponsor(entity)
        login = entity.fetch("login")

        {
          "source" => SOURCE,
          "name" => entity["name"].to_s.empty? ? login : entity.fetch("name"),
          "handle" => login,
          "profile_url" => "https://github.com/#{login}",
          "avatar_url" => entity.fetch("avatarUrl")
        }
      end

      def request
        response = Net::HTTP.post(
          ENDPOINT,
          JSON.generate(query: QUERY, variables: {login: @login, limit: PAGE_LIMIT}),
          "Authorization" => "Bearer #{@token}",
          "Content-Type" => "application/json",
          "User-Agent" => "hanakai-site-sponsors"
        )

        unless response.is_a?(Net::HTTPSuccess)
          raise "GitHub API returned #{response.code}: #{response.body}"
        end

        body = JSON.parse(response.body)

        if body["errors"]
          raise "GitHub API returned errors: #{body["errors"].map { it["message"] }.join("; ")}"
        end

        body.fetch("data")
      end
    end
  end
end
