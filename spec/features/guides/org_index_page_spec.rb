# frozen_string_literal: true

RSpec.feature "Guides / Org index page" do
  let(:guide_repo) { Site::App["repos.guide_repo"] }

  it "renders the guides for an org at a specific version, with links to the other versions" do
    org = "hanami"
    version = "v2.0"
    visit "/guides/#{org}/#{version}"

    expected_guides = guide_repo.all_for(org:, version:)

    within "[data-testid=guides]" do
      guide_titles = page.find_all("a h3").map(&:text)
      expect(guide_titles).to eq expected_guides.map(&:title)

      first_guide = expected_guides.first
      first_card = page.find_all("a").first
      expect(first_card[:href]).to eq first_guide.url_path
    end
  end
end
