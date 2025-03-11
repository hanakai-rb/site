# frozen_string_literal: true

RSpec.feature "Docs / Index page" do
  it "lists all docs across orgs" do
    visit "/docs"

    within "[data-testid=dry-rb-docs]" do
      expect(page.find_all("li a").map(&:text)[0..2]).to eq [
        "dry-cli",
        "dry-operation",
        "dry-types"
      ]
    end
  end
end
