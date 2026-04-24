# auto_register: false
# frozen_string_literal: true

require "hanami/view"
require "json"

# For .xml.builder templates
require "builder"

module Site
  class View < Hanami::View
    include Deps["settings", og_image_manifest: "og_images.manifest"]

    # Used in the app layout
    expose :settings, decorate: false

    expose :og_image_url, layout: true, decorate: false do |context:|
      entry = og_image_manifest.for_url(context.request.path) || og_image_manifest.default_entry
      "#{settings.site_url}#{entry.url_path}"
    end

    expose :og_description, layout: true, decorate: false do |context:|
      entry = og_image_manifest.for_url(context.request.path) || og_image_manifest.default_entry
      entry.description
    end

    expose :og_type, layout: true, decorate: false do |context:|
      entry = og_image_manifest.for_url(context.request.path)
      (entry&.template == "post") ? "article" : "website"
    end

    expose :canonical_page_url, layout: true, decorate: false do |context:|
      "#{settings.site_url}#{context.request.path}"
    end

    expose :theme, layout: true, decorate: false do |context:, org: nil, slug: nil|
      orgs = %w[hanami dry rom]

      # If org was provided explicitly (e.g. from guides actions), trust it
      next org if org && orgs.include?(org)

      "hanakai"
    end
  end
end
