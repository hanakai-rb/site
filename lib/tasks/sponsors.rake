# frozen_string_literal: true

namespace :sponsors do
  desc "Rebuild content/sponsors/sponsors.yml from GitHub Sponsors and Open Collective"
  task :refresh do
    require "hanami/prepare"

    github_token = ENV["SPONSORS_GITHUB_TOKEN"]
    abort "✗ SPONSORS_GITHUB_TOKEN is not set" if github_token.to_s.empty?

    config = Site::Sponsors::Config.load

    result = Site::Sponsors::Refresh.new(
      config:,
      github: Site::Sponsors::GitHub.new(
        login: config.github_login,
        token: github_token
      ),
      open_collective: Site::Sponsors::OpenCollective.new(
        slug: config.open_collective_slug,
        token: ENV["SPONSORS_OPEN_COLLECTIVE_TOKEN"],
        one_time_window_months: config.one_time_donation_months
      )
    ).call

    result.warnings.each { puts "! #{it}" }

    named = result.sponsors.length
    puts "✓ Wrote #{named + result.private_count} sponsors to content/sponsors/sponsors.yml " \
         "(#{named} named, #{result.private_count} private)"
  end
end
