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
      url_path = "/#{rel_path}"

      handler = Site::ContentFileMiddleware::PATH_HANDLERS.find do |handler|
        path = handler.key?(:path_to_url) ? handler[:path_to_url].call(url_path) : url_path
        path.match?(handler[:pattern])
      end

      next unless handler

      # Convert to a path for locating the file
      path = handler.key?(:path_to_url) ? handler[:path_to_url].call(url_path) : url_path
      content_path = handler[:mapper].call(path.match(handler[:pattern]))
      dest_file = content_path.sub("content/", "build/")

      # Copy the file
      FileUtils.mkdir_p(File.dirname(dest_file))
      FileUtils.cp(file, dest_file)
      puts "  Copied: #{file} -> #{dest_file}"
    end

    puts "Content files copied successfully!"
  end
end
