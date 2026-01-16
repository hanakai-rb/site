# frozen_string_literal: true

module Site
  module Content
    class GenerateRedirects
      include Deps["repos.guide_repo"]

      def call
        redirects = []

        # Redirect version-only URLs to the first guide at that version
        versioned_orgs = DEFAULT_GUIDE_VERSIONS.select { |_, version| version }.keys
        versioned_orgs.each do |org|
          guide_repo.org_versions(org:).each do |version|
            first_guide = guide_repo.all_for(org:, version:).min_by(&:position)
            redirects.push("/learn/#{org}/#{version} #{first_guide.url_path}")
          end
        end

        # Redirect versionless URLs to latest guides
        DEFAULT_GUIDE_VERSIONS.each do |org, version|
          if version
            # Redirect org-versioned guides
            guides = guide_repo.all_for(org:, version:)
            first_guide = guides.min_by(&:position)

            redirects
              .push("/learn/#{org}   #{first_guide.url_path}")
              .push("/learn/#{org}/* /learn/#{org}/#{version}/:splat")
          else
            # Redirect self-versioned guides
            guides = guide_repo.latest_for(org:)

            guides.select(&:self_versioned?).each do |guide|
              redirects
                .push("/learn/#{org}/#{guide.slug}   /learn/#{org}/#{guide.slug}/#{guide.version}")
                .push("/learn/#{org}/#{guide.slug}/* /learn/#{org}/#{guide.slug}/#{guide.version}/:splat")
            end
          end
        end

        redirects.join("\n")
      end
    end
  end
end
