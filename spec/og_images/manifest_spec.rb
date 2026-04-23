# frozen_string_literal: true

RSpec.describe Site::OgImages::Manifest do
  subject(:manifest) { Site::App["og_images.manifest"] }

  describe "#all" do
    it "includes the default entry first" do
      expect(manifest.all.first.template).to eq "default"
    end

    it "includes an entry for each blog post" do
      post_outputs = manifest.all.select { |e| e.template == "post" }.map(&:output)
      expect(post_outputs).to all(match(%r{\Ablog/\d{4}/\d{2}/\d{2}/[^/]+\.png\z}))
      expect(post_outputs).not_to be_empty
    end

    it "includes the curated static pages" do
      paths = manifest.all.select { |e| e.template == "page" }.map(&:output)
      expect(paths).to include("home.png", "pages/community.png", "pages/sponsor.png")
    end

    it "carries title, author, date, and org for posts" do
      post_entry = manifest.all.find { |e| e.template == "post" }
      expect(post_entry.data).to include(:title, :author, :date, :org)
    end

    it "includes an entry for each guide page" do
      guide_entries = manifest.all.select { |e| e.template == "guide" }
      expect(guide_entries.size).to be > 100
      expect(guide_entries.map(&:output)).to all(start_with("learn/"))
    end

    it "marks the guide root page with isRoot: true" do
      guide_entries = manifest.all.select { |e| e.template == "guide" }
      root = guide_entries.find { |e| e.data[:isRoot] }
      expect(root).not_to be_nil
      expect(root.data).to include(:guideTitle, :pageTitle, :org)
    end
  end

  describe "#for_url" do
    it "looks up an entry by page URL" do
      home = manifest.for_url("/")
      expect(home).not_to be_nil
      expect(home.output).to eq "home.png"
    end

    it "looks up a post by /blog/<permalink>" do
      post = Site::App["repos.post_repo"].all.first
      entry = manifest.for_url(post.url_path)
      expect(entry).not_to be_nil
      expect(entry.template).to eq "post"
    end

    it "returns nil for unknown URLs" do
      expect(manifest.for_url("/nope")).to be_nil
    end

    it "looks up a guide page by url_path" do
      page = Site::App["repos.guide_repo"].all.first.pages.all.last
      entry = manifest.for_url(page.url_path)
      expect(entry).not_to be_nil
      expect(entry.template).to eq "guide"
    end
  end

  describe "#write" do
    it "serialises a JSON manifest array" do
      io = StringIO.new
      manifest.write(io)
      parsed = JSON.parse(io.string)
      expect(parsed).to be_an(Array)
      expect(parsed.first).to include("output", "template", "data")
    end
  end
end
