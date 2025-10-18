# frozen_string_literal: true

require "json"
require "fileutils"
require "front_matter_parser"
require "commonmarker"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

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

  desc "Build search index for Lunr.js"
  task :build_index do
    puts "Building search index..."

    documents = []

    # Track latest versions per section/subsection
    version_tracker = Hash.new { |h, k| h[k] = [] }

    # Process guides and docs
    ["guides", "docs"].each do |content_type|
      content_dir = File.join("content", content_type)
      next unless Dir.exist?(content_dir)

      # Find all markdown files
      Dir.glob("#{content_dir}/**/*.md").each do |file_path|
        # Parse path: content/guides/dry/v1.0/getting-started/_index.md
        path_parts = file_path.split("/")

        # Skip if not enough parts
        next if path_parts.length < 4

        section = path_parts[2] # dry-*, hanami, rom

        # Determine version and subsection
        # Path can be: content/guides/dry/v1.0/getting-started/_index.md
        # or: content/docs/dry-monads/v1.8/getting-started.md
        version_match = path_parts.find { |p| p =~ /^v\d+/ }
        next unless version_match

        version = version_match

        # Find subsection (the part between section and version, or after version)
        version_index = path_parts.index(version)
        subsection = if version_index > 3
          path_parts[3...version_index].join("/")
        else
          # For guides: content/guides/dry/v1.0/... (no subsection, use section)
          section
        end

        # Parse markdown
        begin
          parsed = FrontMatterParser::Parser.parse_file(file_path)

          title = parsed.front_matter["title"] || File.basename(file_path, ".md").gsub(/[-_]/, " ").capitalize

          # Extract headings
          headings = extract_headings(parsed.content)

          # Clean content (strip markdown, HTML)
          content = clean_content(parsed.content)

          # Build URL path
          url_path = file_path
            .sub("content/", "/")
            .sub(/_index\.md$/, "")
            .sub(/\.md$/, "")
            .sub(%r{/$}, "")  # Remove trailing slash

          # For docs section, remove the redundant first-level directory (dry, hanami, rom)
          if content_type == "docs"
            # Transform /docs/dry/dry-types/... to /docs/dry-types/...
            url_path = url_path.sub(%r{^(/docs/)[^/]+/}, '\1')
          end

          # Create document ID
          doc_id = [section, subsection, version, title]
            .compact
            .join("-")
            .downcase
            .gsub(/[^a-z0-9\-]/, "-").squeeze("-")

          # Extract version number for sorting
          version_number = version.scan(/\d+/).map(&:to_i)
          version_weight = version_number.map.with_index { |n, i| n.to_f / (100**i) }.sum

          doc = {
            id: doc_id,
            title:,
            section:,
            subsection:,
            version:,
            versionWeight: version_weight,
            path: url_path,
            content:,
            headings:,
            isLatest: false # Will be set later
          }

          documents << doc

          # Track versions
          key = "#{section}/#{subsection}"
          version_tracker[key] << {version:, weight: version_weight, doc:}
        rescue => e
          puts "Error processing #{file_path}: #{e.message}"
        end
      end
    end

    # Mark latest versions
    version_tracker.each do |key, versions|
      latest = versions.max_by { |v| v[:weight] }
      latest[:doc][:isLatest] = true if latest
    end

    # Process blog posts (content/posts/YYYY/*.md)
    posts_dir = "content/posts"
    if Dir.exist?(posts_dir)
      Dir.glob("#{posts_dir}/**/*.md").each do |file_path|
        parsed = FrontMatterParser::Parser.parse_file(file_path)

        title = parsed.front_matter["title"] || File.basename(file_path, ".md")
        date = parsed.front_matter["date"]

        # Extract headings and content
        headings = extract_headings(parsed.content)
        content = clean_content(parsed.content)

        # Build URL: content/posts/2022/2022-02-10-title.md -> /blog/2022/2022-02-10-title
        url_path = file_path
          .sub("content/posts/", "/blog/")
          .sub(/\.md$/, "")

        # Create document ID from filename
        doc_id = "blog-#{File.basename(file_path, ".md")}"
          .downcase
          .gsub(/[^a-z0-9\-]/, "-").squeeze("-")

        doc = {
          id: doc_id,
          title:,
          section: "blog",
          path: url_path,
          content:,
          headings:,
          date: date&.to_s
        }

        documents << doc
      rescue => e
        puts "Error processing #{file_path}: #{e.message}"
      end
    end

    # Process community pages (ERB templates)
    community_pages = [
      {file: "app/templates/pages/conduct.html.erb", path: "/conduct", title: "Code of Conduct"},
      {file: "app/templates/pages/community.html.erb", path: "/community", title: "Community"}
    ]

    community_pages.each do |page_info|
      if File.exist?(page_info[:file])
        begin
          file_content = File.read(page_info[:file], encoding: "UTF-8")

          # Extract headings from HTML (h1, h2, h3)
          headings = file_content.scan(/<h[1-3][^>]*>(.*?)<\/h[1-3]>/m).flatten.map do |h|
            h.gsub(/<[^>]+>/, "").strip
          end

          # Clean HTML content for indexing
          content = file_content
            .gsub(/<%.*?%>/m, " ")  # Remove ERB tags
            .gsub(/<script\b[^>]*>.*?<\/script>/m, " ")  # Remove script tags
            .gsub(/<style\b[^>]*>.*?<\/style>/m, " ")  # Remove style tags
            .gsub(/<[^>]+>/, " ")  # Remove all HTML tags
            .gsub(/\s+/, " ")  # Normalize whitespace
            .strip

          doc_id = "community-#{File.basename(page_info[:file], ".html.erb")}"
            .downcase
            .gsub(/[^a-z0-9\-]/, "-")

          doc = {
            id: doc_id,
            title: page_info[:title],
            section: "community",
            path: page_info[:path],
            content: content[0..500],  # Truncate to 500 chars
            headings:
          }

          documents << doc
        rescue => e
          puts "Error processing #{page_info[:file]}: #{e.message}"
        end
      end
    end

    # Ensure tmp and public directories exist
    FileUtils.mkdir_p("tmp")
    FileUtils.mkdir_p("public")

    # Write documents JSON for Node.js script
    File.write("tmp/search-documents.json", JSON.pretty_generate(documents))

    puts "Extracted #{documents.length} documents"
    puts "Running Node.js to build Lunr index..."

    # Clean old search files
    Dir.glob("public/lunr-index.*.json").each(&File.method(:delete))
    Dir.glob("public/search-documents.*.json").each(&File.method(:delete))

    # Run Node.js script to build Lunr index
    result = system("node lib/search/build_lunr_index.mjs")

    if result
      puts "✓ Search index built successfully"
      puts "  - tmp/search-documents.json"
      puts "  - public/search-manifest.json"
      manifest = JSON.parse(File.read("public/search-manifest.json"))
      puts "  - public/lunr-index.#{manifest["checksum"]}.json"
      puts "  - public/search-documents.#{manifest["checksum"]}.json"
    else
      puts "✗ Failed to build Lunr index"
      exit 1
    end
  end

  private

  def extract_headings(markdown_content)
    headings = []
    markdown_content.scan(/^[#]{1,6}\s+(.+)$/) do |match|
      headings << match[0].strip
    end
    headings
  end

  def clean_content(markdown_content)
    # Convert markdown to plain text
    # Remove code blocks
    content = markdown_content.gsub(/```.*?```/m, " ")
    # Remove inline code
    content = content.gsub(/`[^`]+`/, " ")
    # Remove links but keep text
    content = content.gsub(/\[([^\]]+)\]\([^)]+\)/, '\1')
    # Remove images
    content = content.gsub(/!\[([^\]]*)\]\([^)]+\)/, "")
    # Remove HTML tags
    content = content.gsub(/<[^>]+>/, " ")
    # Remove markdown headings markers
    content = content.gsub(/^[#]{1,6}\s+/, "")
    # Remove emphasis markers
    content = content.gsub(/[*_]{1,2}([^*_]+)[*_]{1,2}/, '\1')
    # Normalize whitespace
    content = content.gsub(/\s+/, " ").strip

    # Truncate to reasonable length (first 500 chars for search)
    content[0..500]
  end
end
