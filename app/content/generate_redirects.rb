# frozen_string_literal: true

module Site
  module Content
    class GenerateRedirects
      include Deps["repos.guide_repo"]

      def call
        redirects = []

        Content::DEFAULT_GUIDE_VERSIONS.each do |org, version|
          if version
            # Redirect org-versioned guides
            redirects
              .push("/learn/#{org}   /learn/#{org}/#{version}")
              .push("/learn/#{org}/* /learn/#{org}/#{version}/:splat")
          end

          guide_repo.latest_for(org:).each do |guide|
            next unless guide.self_versioned?

            # Redirect self-versioned guides
            redirects
              .push("/learn/#{org}/#{guide.slug}   /learn/#{org}/#{guide.slug}/#{guide.version}")
              .push("/learn/#{org}/#{guide.slug}/* /learn/#{org}/#{guide.slug}/#{guide.version}/:splat")
          end
        end

        redirects.join("\n")
      end
    end
  end
end
