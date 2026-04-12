# frozen_string_literal: true

RSpec.feature "Community page" do
  it "displays the hero section with community links" do
    visit "/community"

    expect(page).to have_selector "h1", text: "Built on community"
    expect(page).to have_link("Discussion forum", href: "https://discourse.hanamirb.org")
    expect(page).to have_link("Discord", href: "https://discord.com/invite/KFCxDmk3JQ")
    expect(page).to have_link("GitHub", href: "https://github.com/hanami")
    expect(page).to have_link("Code of Conduct", href: "/conduct")
  end

  it "displays all team members in a unified list with core members first" do
    visit "/community"

    expect(page).to have_selector "h2", text: "Our team"

    within "[data-testid=team-roster]" do
      members = page.find_all(".team-member")
      expect(members.length).to eq 17

      # Core members appear first and have the "Core" pill
      first_member = members.first
      expect(first_member).to have_selector "img.avatar"
      expect(first_member).to have_link(href: %r{\Ahttps://github.com/})
      expect(first_member).to have_selector ".core-pill", text: "Core"

      # A non-core member should not have the pill
      # Find a maintainer (they come after the 3 core members)
      fourth_member = members[3]
      expect(fourth_member).not_to have_selector ".core-pill"
    end
  end
end
