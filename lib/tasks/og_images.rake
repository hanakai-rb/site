# frozen_string_literal: true

namespace :og do
  desc "Generate og:images for posts and curated pages"
  task :generate do
    require "fileutils"
    require "hanami/prepare"

    manifest_path = "tmp/og_images/manifest.json"
    FileUtils.mkdir_p(File.dirname(manifest_path))

    File.open(manifest_path, "w") do |f|
      Site::App["og_images.manifest"].write(f)
    end

    puts "==> Rendering og:images..."
    ok = system("node", "bin/og_images/render.mjs", manifest_path)
    abort "✗ og:image generation failed" unless ok
  end
end
