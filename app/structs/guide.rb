# frozen_string_literal: true

module Site
  module Structs
    class Guide < Site::DB::Struct
      def pages
        @pages ||= Content::PageCollection.new(
          root: content_path,
          base_url_path: url_path
        )
      end

      def org_versioned?
        version_scope == "org"
      end

      def self_versioned?
        version_scope == "self"
      end

      def unversioned?
        version_scope == "none"
      end

      def url_path
        if org_versioned?
          "/learn/#{org}/#{version}/#{slug}"
        elsif self_versioned?
          "/learn/#{org}/#{slug}/#{version}"
        else
          "/learn/#{org}/#{slug}"
        end
      end

      def content_path
        if org_versioned?
          Content::GUIDES_PATH.join(org, version, slug)
        elsif self_versioned?
          Content::GUIDES_PATH.join(org, slug, version)
        else
          Content::GUIDES_PATH.join(org, slug)
        end
      end

      def relative_content_path
        content_path.relative_path_from(Content::CONTENT_PATH)
      end
    end
  end
end
