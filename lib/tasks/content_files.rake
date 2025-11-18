# frozen_string_literal: true

namespace :content do
  desc "Copy static content files to build directory"
  task :copy_files do
    require_relative "../site/content_file_middleware"
    require "fileutils"
    require "pathname"

    puts "Copying content files to build directory..."

    content_pattern = "content/**/*.{#{Site::ContentFileMiddleware::ALLOWED_FILE_EXTENSIONS.join(",")}}"
    content_dir = Pathname("content")

    Dir.glob(content_pattern).each do |file|
      next unless File.file?(file)

      # Build a path known to handlers/mappers in content file middlware
      rel_path = Pathname(file).relative_path_from(content_dir).to_s
      url_path = rel_path.start_with?("posts") ? "/#{rel_path.sub("posts", "blog")}" : "/#{rel_path}"

      handler = Site::ContentFileMiddleware::PATH_HANDLERS.find { |h| url_path.match?(h[:pattern]) }
      next unless handler

      # Convert to a path for locating the file
      content_path = handler[:mapper].call(url_path.match(handler[:pattern]))
      dest_file = content_path.sub("content/", "build/").sub("build/posts/", "build/blog/")

      # Copy the file
      FileUtils.mkdir_p(File.dirname(dest_file))
      FileUtils.cp(file, dest_file)
      puts "  Copied: #{file} -> #{dest_file}"
    end

    puts "Content files copied successfully!"
  end
end
