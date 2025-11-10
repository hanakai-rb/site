# frozen_string_literal: true

require "fileutils"

namespace :search do
  desc "Watch content files and rebuild search index on changes"
  task :watch do
    require "listen"

    puts "Watching for content changes..."

    # Build initial index
    system("bin/static-build")
    copy_index_to_public

    listener = Listen.to("content/") do |modified, added, removed|
      changes = (modified + added + removed).select { |f| f.end_with?(".md") }

      if changes.any?
        puts "\nContent changed, rebuilding search index..."
        Rake::Task["search:build_index"].reenable
        Rake::Task["search:build_index"].invoke
      end
    end

    listener.start
    sleep
  end

  desc "Build search index"
  task :build_index do
    system("bin/static-build")
    copy_index_to_public
  end

  def copy_index_to_public
    if Dir.exist?("build/pagefind")
      FileUtils.mkdir_p("public")
      FileUtils.rm_rf("public/pagefind")
      FileUtils.cp_r("build/pagefind", "public/pagefind")
      puts "Copied search index to public/pagefind/ for dev server"
    else
      puts "Warning: build/pagefind/ not found"
    end
  end
end
