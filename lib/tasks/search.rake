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

  task :build_index do

    FileUtils.mkdir_p("public")





    else
      exit 1
    end
  end

end
