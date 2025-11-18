# frozen_string_literal: true

namespace :content do
  desc "Copy static content files to build directory"
  task :copy_files do
    require_relative "../site/content_file_middleware"
    require "fileutils"
    require "pathname"

    puts "Copying content files to build directory..."

    Site::ContentFileMiddleware.new(nil).paths_map.each do |file, url|
      next unless File.file?(file)

      # Copy the file
      dest_file = File.join("build", url)
      FileUtils.mkdir_p(File.dirname(dest_file))
      FileUtils.cp(file, dest_file)
      puts "  Copied: #{file} -> #{dest_file}"
    end

    puts "Content files copied successfully!"
  end
end
