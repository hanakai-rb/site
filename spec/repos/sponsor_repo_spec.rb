# frozen_string_literal: true

RSpec.describe Site::Repos::SponsorRepo do
  subject(:repo) { described_class.new }

  before do
    stub_const(
      "Site::Repos::SponsorRepo::SPONSORS_YML_PATH",
      SPEC_ROOT.join("fixtures/sponsors.yml")
    )
  end

  describe "#individuals" do
    it "returns a sponsor for each named sponsor in the file" do
      named = repo.individuals.reject(&:private?)

      expect(named.map(&:name)).to eq ["Ada Lovelace", "Grace Hopper"]
      expect(named.map(&:source)).to eq ["github", "open_collective"]
      expect(named.map(&:profile_url)).to eq ["https://github.com/ada", "https://opencollective.com/grace"]
    end

    it "expands the private count into sponsors carrying nothing but the flag" do
      private_sponsors = repo.individuals.select(&:private?)

      expect(private_sponsors.length).to eq 2
      expect(private_sponsors.map(&:attributes)).to all eq(private: true)
    end

    it "lists the named sponsors before the private ones" do
      expect(repo.individuals.map(&:private?)).to eq [false, false, true, true]
    end
  end

  describe "actual sponsors data" do
    it "loads into sponsors" do
      expect(repo.individuals).to all be_a Site::Structs::Sponsor
      expect(repo.individuals).not_to be_empty
    end
  end
end
