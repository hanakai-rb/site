# frozen_string_literal: true

RSpec.feature "Guides / Redirects" do
  describe "org-versioned guides" do
    it "redirects versionless (root) guide URLs to that guide in the latest version" do
      visit "/learn/hanami/getting-started"

      expect(URI(current_url).path).to eq "/learn/hanami/v2.3/getting-started"
    end

    it "redirects versionless (deep) guide URLs to that guide and path in the latest version" do
      visit "/learn/hanami/getting-started/building-a-web-app"

      expect(URI(current_url).path).to eq "/learn/hanami/v2.3/getting-started/building-a-web-app"
    end

    it "redirects version-only org guide URLs to the first guide of the latest version" do
      visit "/learn/hanami/v2.3"

      expect(URI(current_url).path).to eq "/learn/hanami/v2.3/getting-started"
    end
  end

  describe "self-versioned guides" do
    it "redirects versionless (root) guide URLs to the guide at the latest version" do
      visit "/learn/dry/dry-types"

      expect(URI(current_url).path).to eq "/learn/dry/dry-types/v1.8"
    end

    it "redirects versionless (deep) guide URLs to that guide and path at the latest version" do
      visit "/learn/dry/dry-types/default-values"

      expect(URI(current_url).path).to eq "/learn/dry/dry-types/v1.8/default-values"
    end
  end
end
