# frozen_string_literal: true

RSpec.describe "search index", type: :request do
  before do
    # Ensure search index is built
    unless File.exist?("public/pagefind/pagefind-entry.json")
      require "rake"
      load File.expand_path("../../Rakefile", __dir__)
      Rake::Task["search:build_index"].invoke
    end
  end

  let(:pagefind_entry) { JSON.parse(File.read("public/pagefind/pagefind-entry.json")) }

  describe "pagefind index files" do
    it "creates the pagefind directory" do
      expect(File.directory?("public/pagefind")).to be true
    end

    it "creates the pagefind-entry.json file" do
      expect(File.exist?("public/pagefind/pagefind-entry.json")).to be true
    end

    it "serves the main pagefind.js file" do
      response = get "/pagefind/pagefind.js"

      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to include("application/javascript")
    end

    it "serves the pagefind UI files" do
      response = get "/pagefind/pagefind-ui.js"

      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to include("application/javascript")
    end

    it "serves the pagefind UI CSS" do
      response = get "/pagefind/pagefind-ui.css"

      expect(response.status).to eq(200)
      expect(response.headers["Content-Type"]).to include("text/css")
    end
  end

  describe "search index coverage" do
    it "indexes an expected number of pages" do
      page_count = pagefind_entry.dig("languages", "en", "page_count")
      expect(page_count).to be > 100
    end
  end

  describe "indexed content verification" do
    # Helper to decompress and parse all fragments
    def load_all_fragments
      fragment_files = Dir.glob("public/pagefind/fragment/*.pf_fragment")

      fragment_files.map do |file|
        compressed = File.read(file, mode: "rb")

        # Decompress using zlib
        require "zlib"
        gz = Zlib::GzipReader.new(StringIO.new(compressed))
        decompressed = gz.read
        gz.close

        # Skip pagefind_dcd signature if present
        if decompressed[0..11] == "pagefind_dcd"
          decompressed = decompressed[12..]
        end

        JSON.parse(decompressed)
      end
    end

    let(:fragments) { load_all_fragments }

    it "includes guides and docs" do
      guide_urls = fragments.map { |f| f["url"] }
        .select { |url| url =~ %r{/guides/(hanami|rom|dry)/} }

      expect(guide_urls.length).to be > 0
    end

    it "removes trailing slashes from indexed paths" do
      fragments.each do |fragment|
        expect(fragment["url"]).not_to end_with("/"),
          "Path should not end with /: #{fragment["url"]}"
      end
    end
  end
end
