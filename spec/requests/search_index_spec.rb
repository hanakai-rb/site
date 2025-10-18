# frozen_string_literal: true

RSpec.describe "search index", type: :request do
  before do
    # Ensure search index is built
    unless File.exist?("public/search-manifest.json")
      require "rake"
      load File.expand_path("../../Rakefile", __dir__)
      Rake::Task["search:build_index"].invoke
    end
  end

  let(:manifest) { JSON.parse(File.read("public/search-manifest.json")) }
  let(:checksum) { manifest["checksum"] }

  describe "versioned search files" do
    it "serves the lunr index with checksum in filename" do
      response = get "/lunr-index.#{checksum}.json"

      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to include("application/json")
      expect(response.headers["ETag"].to_s).not_to be_empty
    end

    it "serves the search documents with checksum in filename" do
      response = get "/search-documents.#{checksum}.json"

      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to include("application/json")
      expect(response.headers["ETag"].to_s).not_to be_empty
    end

    it "returns 404 for non-existent checksums" do
      response = get "/lunr-index.invalid00.json"

      expect(response.status).to eq(404)
    end
  end

  describe "search index content" do
    let(:documents) { JSON.parse(File.read("public/search-documents.#{checksum}.json")) }

    it "includes guides and docs" do
      guides = documents.select { |d| d["section"].match?(/hanami|rom|dry/) }
      expect(guides.length).to be > 0
    end

    it "includes blog posts" do
      blog_posts = documents.select { |d| d["section"] == "blog" }
      expect(blog_posts.length).to be > 0

      # Check blog posts have required fields
      blog_post = blog_posts.first
      expect(blog_post).to have_key("title")
      expect(blog_post).to have_key("path")
      expect(blog_post).to have_key("content")
      expect(blog_post).to have_key("date")
      expect(blog_post["path"]).to start_with("/blog/")
    end

    it "includes community pages" do
      community_pages = documents.select { |d| d["section"] == "community" }
      expect(community_pages.length).to eq(2)

      # Check for conduct and community pages
      paths = community_pages.map { |p| p["path"] }
      expect(paths).to include("/conduct")
      expect(paths).to include("/community")
    end

    it "includes required fields for all documents" do
      documents.each do |doc|
        expect(doc).to have_key("id")
        expect(doc).to have_key("title")
        expect(doc).to have_key("section")
        expect(doc).to have_key("path")
        expect(doc).to have_key("content")
        expect(doc).to have_key("headings")
      end
    end

    it "marks latest versions for guides and docs" do
      versioned_docs = documents.select { |d| d["version"] }
      latest_docs = versioned_docs.select { |d| d["isLatest"] }

      expect(latest_docs.length).to be > 0
    end

    it "removes trailing slashes from paths" do
      documents.each do |doc|
        expect(doc["path"]).not_to end_with("/"), "Path should not end with /: #{doc["path"]}"
      end
    end
  end

  describe "checksum embedding in HTML" do
    it "checksum is available from manifest file" do
      # The checksum is read from public/search-manifest.json at runtime
      # and embedded in the HTML via the search_checksum expose in app/view.rb
      expect(checksum).to match(/^[a-f0-9]{8}$/)
      expect(File.exist?("public/search-manifest.json")).to be true
    end
  end
end
