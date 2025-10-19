# frozen_string_literal: true

RSpec.feature "Docs / Index page" do
  let(:doc_repo) { Site::App["repos.doc_repo"] }

  it "lists all docs across orgs" do
    visit "/docs"

    expected_docs = doc_repo.latest_by_org

    expected_docs.each do |org, docs|
      within "[data-testid=#{org}-docs]" do
        doc_titles = page.find_all("a h3").map(&:text)
        expect(doc_titles).to eq docs.map(&:title)
      end
    end

    within "[data-testid=docs-list]" do
      expected_docs.each do |org, docs|
        docs.each do |doc|
          expect(page).to have_link doc.title
        end
      end
    end
  end
end
