# frozen_string_literal: true

require "bundler/setup"
require "sitemap_generator"
require "hanami/prepare"

app = Hanami.app

SitemapGenerator::Sitemap.default_host = app["settings"].site_url

SitemapGenerator::Sitemap.create do
  # Projects
  add "/hanami"
  add "/dry"
  add "/rom"

  # Pages
  add "/community"
  add "/conduct"
  add "/sponsor"
  add "/status"
  add "/ai-policy"

  # Guides
  add "/learn"

  guide_repo = app["repos.guide_repo"]
  listed_guides = guide_repo.all.reject(&:unlisted)

  # Org-versioned guide version indexes (e.g. /learn/hanami/v2.3)
  guide_repo.listed_versions_by_org.each do |org, versions|
    versions.each do |version|
      add "/learn/#{org}/#{version}"
    end
  end

  # Self-versioned guide indexes (e.g. /learn/dry/dry-types)
  listed_guides.select(&:self_versioned?).map { |g| [g.org, g.slug] }.uniq.each do |org, slug|
    add "/learn/#{org}/#{slug}"
  end

  # Unversioned guide URLs (e.g. /learn/dry/getting-started) are the canonical guide URL itself,
  # added by the loop below.
  listed_guides.each do |guide|
    add guide.url_path

    guide.pages.all.each do |page|
      add page.url_path
    end
  end

  # Blog
  add "/blog"

  1.upto(app["repos.post_repo"].total_pages) do |page|
    add "/blog/page/#{page}"
  end

  app["repos.post_repo"].all.each do |post|
    add post.url_path
  end
end
