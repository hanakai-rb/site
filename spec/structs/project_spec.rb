# frozen_string_literal: true

RSpec.describe Site::Structs::Project do
  describe "#label" do
    it "is the repo name without the organization" do
      project = described_class.new(repo: "hanami/hanami-controller")
      expect(project.label).to eq("hanami-controller")
    end
  end
  describe "#org" do
    it "identifies dry org" do
      project = described_class.new(repo: "dry-rb/dry-configurable")
      expect(project.org).to eq(:dry)
    end
    it "identifies hanami org" do
      project = described_class.new(repo: "hanami/hanami-controller")
      expect(project.org).to eq(:hanami)
    end
    it "identifies rom org" do
      project = described_class.new(repo: "rom-rb/rom-http")
      expect(project.org).to eq(:rom)
    end
  end
  describe "#version_badge_image_url" do
    it "uses badge.fury.io" do
      project = described_class.new(repo: "hanami/hanami-controller")
      expect(project.version_badge_image_url).to eq("https://badge.fury.io/rb/hanami-controller.svg")
    end
  end
end
