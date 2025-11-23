# frozen_string_literal: true

RSpec.describe "static content files", type: :request do
  it "serves static files within the guide" do
    response = get "/learn/rom/v5.0/getting-started/images/rom-overview.jpg"

    expect(response.status).to eq(200)
    expect(response.headers["Content-Type"]).to eq("image/jpeg")
    expect(response.headers["ETag"].to_s).not_to be_empty
    expect(response.headers["Cache-Control"]).to eq("public, max-age=31536000, must-revalidate")
  end

  it "serves static files within the blog post" do
    response = get "/blog/assets/2025-06-26-meet-tim-and-sean/sean-and-tim.jpeg"

    expect(response.status).to eq(200)
    expect(response.headers["Content-Type"]).to eq("image/jpeg")
    expect(response.headers["ETag"].to_s).not_to be_empty
    expect(response.headers["Cache-Control"]).to eq("public, max-age=31536000, must-revalidate")
  end
end
