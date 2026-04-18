# auto_register: false
# frozen_string_literal: true

require "cgi"
require "erb"
require "nokogiri"

module Site
  module Content
    module Filters
      # Replaces logo shortcodes in rendered content with inline SVGs:
      #
      #   🌸, :hanami:  → Hanami logo
      #   :hanakai:     → Hanakai logo
      #   :rom:         → ROM logo
      #   :dry:         → Dry logo
      #
      # Skips text inside `<code>` and `<pre>`, so code samples containing the
      # shortcodes pass through untouched.
      class EmojiLogoFilter
        def self.load_svg(name)
          path = File.expand_path("../../templates/svgs/_#{name}_logo_simple.html.erb", __dir__)
          ERB.new(File.read(path))
            .result_with_hash(
              class_name: "emoji-logo emoji-logo--#{name} inline",
              height: "1em",
              width: "1em"
            )
            .gsub(/\s+/, " ")
            .strip
        end

        HANAMI_SVG = load_svg("hanami")
        HANAKAI_SVG = load_svg("hanakai")
        ROM_SVG = load_svg("rom")
        DRY_SVG = load_svg("dry")

        REPLACEMENTS = {
          "🌸" => HANAMI_SVG,
          ":hanami:" => HANAMI_SVG,
          ":hanakai:" => HANAKAI_SVG,
          ":rom:" => ROM_SVG,
          ":dry:" => DRY_SVG
        }.freeze

        PATTERN = Regexp.union(REPLACEMENTS.keys)
        SPLIT_PATTERN = /(#{PATTERN})/

        def call(html)
          return html unless html.match?(PATTERN)

          doc = Nokogiri::HTML::DocumentFragment.parse(html)

          doc.xpath(".//text()[not(ancestor::code) and not(ancestor::pre)]").each do |node|
            next unless node.content.match?(PATTERN)

            rebuilt = node.content.split(SPLIT_PATTERN).map { |part|
              REPLACEMENTS[part] || CGI.escapeHTML(part)
            }.join
            node.replace(Nokogiri::HTML::DocumentFragment.parse(rebuilt))
          end

          doc.to_html
        end
      end
    end
  end
end
