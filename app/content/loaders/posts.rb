# frozen_string_literal: true

require "front_matter_parser"
require "time"

module Site
  module Content
    module Loaders
      # Loads posts from content/blog/ into the database.
      class Posts
        PostData = Data.define(:permalink, :title, :published_at, :author, :excerpt, :content)

        include Deps[posts_relation: "relations.posts"]

        def call(root: POSTS_PATH)
          root.glob("**/*.md").each do |post_path|
            parsed_file = FrontMatterParser::Parser.parse_file(post_path)
            front_matter = parsed_file.front_matter.transform_keys(&:to_sym)

            post = PostData.new(
              permalink: permalink_from_file_name(post_path.basename),
              title: front_matter.fetch(:title),
              published_at: Time.parse(front_matter.fetch(:date)),
              author: front_matter.fetch(:author),
              excerpt: front_matter[:excerpt],
              content: parsed_file.content
            )

            posts_relation.insert(post.to_h)
          end
        end

        private

        def permalink_from_file_name(file_name)
          name = File.basename(file_name, File.extname(file_name))

          name.match(FILE_NAME_REGEXP)[1..4].join("/")
        end

        FILE_NAME_REGEXP = /^(\d{4})-(\d{2})-(\d{2})-(.*?)$/
      end
    end
  end
end
