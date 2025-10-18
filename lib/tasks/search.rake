# frozen_string_literal: true
# encoding: utf-8

require "json"
require "fileutils"
require "front_matter_parser"
require "commonmarker"

Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8

namespace :search do
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

        section = path_parts[2] # dry, hanami, rom

        # Determine version and subsection
        # Path can be: content/guides/dry/v1.0/getting-started/_index.md
        # or: content/docs/dry/dry-monads/v1.8/getting-started.md
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
          file_content = File.read(file_path, encoding: "UTF-8")
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

          # Create document ID
          doc_id = [section, subsection, version, title]
            .compact
            .join("-")
            .downcase
            .gsub(/[^a-z0-9\-]/, "-")
            .gsub(/-+/, "-")

          # Extract version number for sorting
          version_number = version.scan(/\d+/).map(&:to_i)
          version_weight = version_number.map.with_index { |n, i| n.to_f / (100 ** i) }.sum

          doc = {
            id: doc_id,
            title: title,
            section: section,
            subsection: subsection,
            version: version,
            versionWeight: version_weight,
            path: url_path,
            content: content,
            headings: headings,
            isLatest: false # Will be set later
          }

          documents << doc

          # Track versions
          key = "#{section}/#{subsection}"
          version_tracker[key] << { version: version, weight: version_weight, doc: doc }
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

    # Ensure tmp and public directories exist
    FileUtils.mkdir_p("tmp")
    FileUtils.mkdir_p("public")

    # Write documents JSON for Node.js script
    File.write("tmp/search-documents.json", JSON.pretty_generate(documents))

    puts "Extracted #{documents.length} documents"
    puts "Running Node.js to build Lunr index..."

    # Run Node.js script to build Lunr index
    result = system("node lib/search/build_lunr_index.mjs")

    if result
      puts "✓ Search index built successfully"
      puts "  - tmp/search-documents.json"
      puts "  - public/search-documents.json"
      puts "  - public/lunr-index.json"
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
