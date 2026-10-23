# frozen_string_literal: true

require "yaml"

module Site
  module Sponsors
    # The hand-maintained rules that shape the generated sponsors list.
    #
    # See content/sponsors/config.yml for what each rule does.
    class Config
      DEFAULT_PATH = App.root.join("content/sponsors/config.yml")

      def self.load(path = DEFAULT_PATH)
        new(**YAML.load_file(path, symbolize_names: true))
      end

      attr_reader :github_login, :open_collective_slug, :one_time_donation_months, :exclude, :extra

      def initialize(github_login:, open_collective_slug:, one_time_donation_months:, exclude: [], extra: [])
        @github_login = github_login
        @open_collective_slug = open_collective_slug
        @one_time_donation_months = one_time_donation_months
        @exclude = (exclude || []).map(&:to_s).to_set
        @extra = (extra || []).map { it.transform_keys(&:to_s) }
      end

      def excluded?(handle)
        exclude.include?(handle)
      end
    end
  end
end
