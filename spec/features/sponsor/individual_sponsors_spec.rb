# frozen_string_literal: true

RSpec.feature "Individual sponsors" do
  before { visit "/sponsor" }

  let(:entries) { page.all("[data-testid=individual-sponsor]") }

  it "counts the sponsors it shows" do
    expect(entries).not_to be_empty
    expect(page).to have_text "Thank you to our #{entries.length} individual sponsors"
  end

  it "shows each sponsor as a linked avatar, or as an unnamed padlock when they are private" do
    entries.each do |entry|
      if entry[:title] == "Private sponsor"
        expect(entry).to have_no_selector "img"
      else
        expect(entry[:href]).to start_with "https://"
        expect(entry.find("img")[:src]).to start_with "https://"
      end
    end
  end
end
