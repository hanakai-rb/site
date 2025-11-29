# frozen_string_literal: true

RSpec.feature "Guides / Redirects" do
  it "redirects versionless (root) guide URLs to the default version" do
    visit "/learn/hanami/getting-started"

    redirected_path = URI(current_url).path
    expect(redirected_path).to eq "/learn/hanami/v2.3/getting-started"
  end

  it "redirects versionless (deep) guide URLs to the default version" do
    visit "/learn/hanami/getting-started/building-a-web-app"

    redirected_path = URI(current_url).path
    expect(redirected_path).to eq "/learn/hanami/v2.3/getting-started/building-a-web-app"
  end
end
