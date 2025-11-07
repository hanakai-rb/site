# frozen_string_literal: true

require "fileutils"

namespace :search do
  desc "Watch content files and rebuild search index on changes"
  task :watch do
    require "listen"

    puts "👀 Watching for content changes..."

    # Build initial index
    Rake::Task["search:build_index"].invoke

    listener = Listen.to("content/") do |modified, added, removed|
      changes = (modified + added + removed).select { |f| f.end_with?(".md") }

      if changes.any?
        puts "\n🔄 Content changed, rebuilding search index..."
        Rake::Task["search:build_index"].reenable
        Rake::Task["search:build_index"].invoke
      end
    end

    listener.start
    sleep
  end

  desc "Build search index using Pagefind"
  task :build_index do
    puts "Building Pagefind search index..."

    # Ensure public directory exists
    FileUtils.mkdir_p("public")

    # Remove old pagefind directory
    FileUtils.rm_rf("public/pagefind")

    # Run Pagefind to index the public directory
    result = system("npx pagefind --site build --output-path public/pagefind")

    if result
      # Calculate total size of pagefind directory
      total_size = Dir.glob("public/pagefind/**/*")
        .select { |f| File.file?(f) }
        .sum { |f| File.size(f) }

      size_kb = (total_size / 1024.0).round(2)

      puts "✓ Pagefind index built successfully"
      puts "  - public/pagefind/"
      puts "  - Index size: #{size_kb}KB"
    else
      puts "✗ Failed to build Pagefind index"
      exit 1
    end
  end
end
