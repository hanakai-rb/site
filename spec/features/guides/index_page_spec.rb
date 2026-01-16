# frozen_string_literal: true

RSpec.feature "Guides / Index page" do
  let(:guide_repo) { Site::App["repos.guide_repo"] }

  xit "lists all the guides and versions across orgs" do
    visit "/learn"

    expected_guides = guide_repo.latest_by_org

    expected_guides.each do |org, guides|
      within "[data-testid=#{org}-guides]" do
        guide_titles = page.find_all("a h3").map(&:text)
        expect(guide_titles).to eq guides.map(&:title)
      end
    end

    expected_versions = guide_repo.versions_by_org
    expected_versions.each do |org, versions|
      within "[data-testid=#{org}-versions]" do
        expect(page).to have_content versions.first
      end
    end

    within "[data-testid=guides-list]" do
      expected_guides.each do |org, guides|
        guides.each do |guide|
          expect(page).to have_link guide.title
        end
      end
    end
  end
end
