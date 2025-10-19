# frozen_string_literal: true

RSpec.feature "Team Members" do
  it "displays core and maintainer teams" do
    visit "/community"

    expect(page).to have_selector "h2", text: "Core Team"

    within "[data-testid=core-team]" do
      core_members = page.find_all(".team-member")
      expect(core_members.length).to be >= 1

      first_member = core_members.first
      expect(first_member).to have_selector "img.avatar"
      expect(first_member).to have_selector "h3"
      expect(first_member).to have_selector "p svg"
      expect(first_member).to have_link(href: %r{\Ahttps://github.com/})
    end

    expect(page).to have_selector "h2", text: "Maintainers"

    within "[data-testid=maintainers-team]" do
      maintainer_members = page.find_all(".team-member")
      expect(maintainer_members.length).to be >= 1

      first_member = maintainer_members.first
      expect(first_member).to have_selector "img.avatar"
      expect(first_member).to have_selector "h3"
      expect(first_member).to have_selector "p svg"
      expect(first_member).to have_link(href: %r{\Ahttps://github.com/})
    end
  end
end
