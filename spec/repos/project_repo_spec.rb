# frozen_string_literal: true

RSpec.describe Site::Repos::ProjectRepo do
  describe "#hanami_projects" do
    it "includes hanami repos" do
      repo = described_class.new
      expect(repo.hanami_projects.map(&:repo)).to include "hanami/hanami-cli"
    end
  end
end
