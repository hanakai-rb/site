# frozen_string_literal: true

module Site
  module Content
    class GenerateRedirects
      def call
        redirects = []

        Content::DEFAULT_GUIDE_VERSIONS.each do |org, version|
          redirects
            .push("/guides/#{org}    /guides/#{org}/#{version}")
            .push("/guides/#{org}/*  /guides/#{org}/#{version}/:splat")
        end

        end

        redirects.join("\n")
      end
    end
  end
end
