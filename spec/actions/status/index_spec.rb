# frozen_string_literal: true

RSpec.describe Site::Actions::Status::Index do
  let(:params) { {} }

  it "works" do
    response = subject.call(params)
    expect(response).to be_successful
  end

  it "has a title" do
    response = subject.call(params)
    parsed = Nokogiri.HTML(response.body.join)
    expect(parsed.xpath("//title").text).to include "Status"
  end
end
