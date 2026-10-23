# frozen_string_literal: true

RSpec.describe Site::Sponsors::Compiler do
  subject(:compiler) { described_class.new(config) }

  let(:config) {
    Site::Sponsors::Config.new(
      github_login: "hanami",
      open_collective_slug: "hanami",
      one_time_donation_months: 12,
      **config_rules
    )
  }
  let(:config_rules) { {} }

  def listing(sponsors = [], private_count: 0)
    Site::Sponsors::Listing.new(sponsors:, private_count:)
  end

  def github_sponsor(handle, name: handle)
    {
      "source" => "github", "name" => name, "handle" => handle,
      "profile_url" => "https://github.com/#{handle}", "avatar_url" => "https://example.com/#{handle}.png"
    }
  end

  def open_collective_sponsor(handle, name: handle)
    {
      "source" => "open_collective", "name" => name, "handle" => handle,
      "profile_url" => "https://opencollective.com/#{handle}", "avatar_url" => "https://example.com/#{handle}.png"
    }
  end

  it "merges both sources, sorted by name" do
    result = compiler.call(
      github: listing([github_sponsor("zoe", name: "Zoe"), github_sponsor("ada", name: "Ada")]),
      open_collective: listing([open_collective_sponsor("mo", name: "Mo")])
    )

    expect(result.sponsors.map { it["name"] }).to eq ["Ada", "Mo", "Zoe"]
  end

  it "sorts by name without regard to case" do
    result = compiler.call(
      github: listing([github_sponsor("b", name: "bob"), github_sponsor("a", name: "Ada")]),
      open_collective: listing
    )

    expect(result.sponsors.map { it["name"] }).to eq ["Ada", "bob"]
  end

  it "adds up the private sponsors of both platforms" do
    result = compiler.call(
      github: listing([github_sponsor("zoe", name: "Zoe")], private_count: 1),
      open_collective: listing(private_count: 5)
    )

    expect(result.private_count).to eq 6
    expect(result.sponsors.length).to eq 1
  end

  describe "exclusions" do
    let(:config_rules) { {exclude: ["serp_api"]} }

    it "drops excluded handles and says so" do
      result = compiler.call(
        github: listing([github_sponsor("ada", name: "Ada")]),
        open_collective: listing([open_collective_sponsor("serp_api", name: "SerpApi")])
      )

      expect(result.sponsors.map { it["handle"] }).to eq ["ada"]
      expect(result.warnings).to include(/Excluded open_collective sponsor serp_api/)
    end
  end

  it "lists someone who sponsors on both platforms once for each" do
    result = compiler.call(
      github: listing([github_sponsor("ada", name: "Ada")]),
      open_collective: listing([open_collective_sponsor("ada", name: "Ada")])
    )

    expect(result.sponsors.map { it["source"] }).to eq ["github", "open_collective"]
    expect(result.warnings).to be_empty
  end

  describe "extra sponsors" do
    let(:config_rules) {
      {extra: [{"name" => "Mo", "profile_url" => "https://example.com", "avatar_url" => "https://example.com/mo.png"}]}
    }

    it "adds them to the list, in name order" do
      result = compiler.call(
        github: listing([github_sponsor("zoe", name: "Zoe"), github_sponsor("ada", name: "Ada")]),
        open_collective: listing
      )

      expect(result.sponsors.map { it["name"] }).to eq ["Ada", "Mo", "Zoe"]
    end
  end
end
