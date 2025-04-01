# frozen_string_literal: true

require "bundler/setup"
require "sitemap_generator"
require "hanami/prepare"

app = Hanami.app

SitemapGenerator::Sitemap.default_host = app["settings"].site_url

SitemapGenerator::Sitemap.create do
  # Pages
  add "/community"
  add "/conduct"
  add "/sponsor"

  # Guides
  add "/guides"

  app["repos.guide_repo"].versions_by_org.each do |org, versions|
    versions.each do |version|
      add "/guides/#{org}/#{version}"
    end
  end

  app["repos.guide_repo"].all.each do |guide|
    add guide.url_path

    guide.pages.all.each do |page|
      add page.url_path
    end
  end

  # Docs
  add "/docs"

  app["repos.doc_repo"].all.each do |doc|
    add doc.url_path

    doc.pages.all.each do |page|
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
