# frozen_string_literal: true

require "json"

module Site
  module OgImages
    # Builds the list of og:images to render at build time.
    class Manifest
      include Deps["repos.post_repo", "repos.guide_repo"]

      DEFAULT_OUTPUT = "default.png"

      STATIC_PAGES = [
        {
          path: "/",
          output: "home.png",
          template: "page",
          data: {
            title: "Let your Ruby bloom",
            subtitle: "A family of Ruby tools that help you write clearer, more maintainable apps",
            org: "hanakai"
          }
        },
        {
          path: "/community",
          output: "pages/community.png",
          template: "page",
          data: {
            title: "Community",
            subtitle: "A place where people of all backgrounds and experience levels can feel respected, and can share and grow",
            org: "hanakai"
          }
        },
        {
          path: "/sponsor",
          output: "pages/sponsor.png",
          template: "page",
          data: {
            title: "Sponsor Hanakai",
            subtitle: "Help us build a diverse future for Ruby",
            org: "hanakai"
          }
        },
        {
          path: "/conduct",
          output: "pages/conduct.png",
          template: "page",
          data: {title: "Code of conduct", org: "hanakai"}
        },
        {
          path: "/ai-policy",
          output: "pages/ai-policy.png",
          template: "page",
          data: {title: "AI contribution policy", org: "hanakai"}
        },
        {
          path: "/hanami",
          output: "pages/hanami.png",
          template: "page",
          data: {
            title: "Hanami",
            subtitle: "A complete framework for building apps with structure and clarity",
            org: "hanami"
          }
        },
        {
          path: "/dry",
          output: "pages/dry.png",
          template: "page",
          data: {
            title: "Dry",
            subtitle: "Validation, types, functional patterns and more, for robust code in any Ruby app",
            org: "dry"
          }
        },
        {
          path: "/rom",
          output: "pages/rom.png",
          template: "page",
          data: {
            title: "Rom",
            subtitle: "A powerful and flexible persistence toolkit that keeps your domain logic clean",
            org: "rom"
          }
        },
        {
          path: "/blog",
          output: "pages/blog.png",
          template: "page",
          data: {
            title: "Blog",
            subtitle: "News and writing from the Hanakai community",
            org: "hanakai"
          }
        },
        {
          path: "/learn",
          output: "pages/learn.png",
          template: "page",
          data: {
            title: "Learn",
            subtitle: "Guides for Hanami, Dry, and Rom",
            org: "hanakai"
          }
        }
      ].freeze

      DEFAULT_ENTRY_DATA = {
        title: "Hanakai",
        subtitle: "Hanami, Dry, and Rom",
        org: "hanakai"
      }.freeze

      def all
        [default_entry, *static_entries, *post_entries, *guide_entries]
      end

      # Look up the og:image entry for a given page URL. Returns nil if the
      # page doesn't have a dedicated image (callers should fall back to the
      # default).
      def for_url(url)
        index.fetch(url, nil)
      end

      def default_entry
        Entry.new(
          output: DEFAULT_OUTPUT,
          template: "default",
          data: DEFAULT_ENTRY_DATA.dup
        )
      end

      def write(io)
        io.write(JSON.pretty_generate(all.map(&:to_manifest_entry)))
      end

      private

      def index
        @index ||= {"default" => default_entry}
          .merge(static_entries_by_url)
          .merge(post_entries_by_url)
          .merge(guide_entries_by_url)
      end

      def static_entries
        STATIC_PAGES.map { |spec| Entry.new(output: spec[:output], template: spec[:template], data: spec[:data].dup) }
      end

      def static_entries_by_url
        STATIC_PAGES.zip(static_entries).to_h { |spec, entry| [spec[:path], entry] }
      end

      def post_entries
        post_repo.all.map { |post| post_entry(post) }
      end

      def post_entries_by_url
        post_repo.all.to_h { |post| [post.url_path, post_entry(post)] }
      end

      def post_entry(post)
        Entry.new(
          output: "blog/#{post.permalink}.png",
          template: "post",
          data: {
            title: post.title,
            author: post.author,
            date: post.published_at&.strftime("%B %d, %Y"),
            org: post.org,
            excerpt: post[:excerpt]&.strip
          }.compact
        )
      end

      def guide_entries
        guide_repo.all.flat_map { |guide| guide_page_entries(guide) }
      end

      def guide_entries_by_url
        guide_repo.all.flat_map { |guide|
          guide.pages.all.map { |page| [page.url_path, guide_page_entry(guide, page)] }
        }.to_h
      end

      def guide_page_entries(guide)
        guide.pages.all.map { |page| guide_page_entry(guide, page) }
      end

      def guide_page_entry(guide, page)
        is_root = page.url_path == guide.url_path

        Entry.new(
          output: "learn#{page.url_path.delete_prefix("/learn")}.png",
          template: "guide",
          data: {
            version: guide.version,
            guideTitle: guide.title,
            pageTitle: page.title,
            isRoot: is_root,
            org: guide.org,
            description: guide.description
          }.compact
        )
      end
    end
  end
end
