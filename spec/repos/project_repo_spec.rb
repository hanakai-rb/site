# frozen_string_literal: true

RSpec.describe Site::Repos::ProjectRepo do
  describe "#dry_projects" do
    it "includes dry repos" do
      repo = described_class.new
      expect(repo.dry_projects.map(&:repo)).to include "dry-rb/dry-inflector"
    end
  end
  describe "#hanami_projects" do
    it "includes hanami repos" do
      repo = described_class.new
      expect(repo.hanami_projects.map(&:repo)).to include "hanami/hanami-cli"
    end
  end
  describe "#rom_projects" do
    it "includes rom repos" do
      repo = described_class.new
      expect(repo.rom_projects.map(&:repo)).to include "rom-rb/rom-sql"
    end
  end
end
