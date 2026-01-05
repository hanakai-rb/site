# frozen_string_literal: true

RSpec.describe Site::Structs::Project do
  describe "#label" do
    it "is the repo name without the organization" do
      project = described_class.new(repo: "hanami/hanami-controller")
      expect(project.label).to eq("hanami-controller")
    end
  end
  describe "#version_badge_image_url" do
    it "uses badge.fury.io" do
      project = described_class.new(repo: "hanami/hanami-controller")
      expect(project.version_badge_image_url).to eq("https://badge.fury.io/rb/hanami-controller.svg")
    end
  end
end
