# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"

RSpec.describe Site::Content::Filters::InternalLinksFilter do
  let(:context) {
    {
      internal_links: {
        page: ->(path) { "/learn/dry/dry-cli/v2.0#{path}" },
        file: ->(path) { "/learn/dry/dry-cli/v2.0#{path}" }
      }
    }
  }

  def call(markdown)
    pipeline = HTMLPipeline.new(
      convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new,
      node_filters: [described_class.new],
      sanitization_config: nil
    )
    pipeline.call(markdown, context: context).fetch(:output).to_s
  end

  it "rewrites an internal link" do
    expect(call("[Options](//page/options)")).to include %(href="/learn/dry/dry-cli/v2.0/options")
  end

  it "keeps the fragment of an internal link" do
    output = call("[Casting](//page/options#casting-values)")

    expect(output).to include %(href="/learn/dry/dry-cli/v2.0/options#casting-values")
  end

  it "keeps the query of an internal link" do
    output = call("[Options](//page/options?tab=ruby#casting-values)")

    expect(output).to include %(href="/learn/dry/dry-cli/v2.0/options?tab=ruby#casting-values")
  end

  it "keeps the fragment of an internal image" do
    output = call("![Diagram](//file/diagram.svg#dark)")

    expect(output).to include %(src="/learn/dry/dry-cli/v2.0/diagram.svg#dark")
  end

  it "leaves other links alone" do
    expect(call("[Section](#casting-values)")).to include %(href="#casting-values")
    expect(call("[Ruby](https://www.ruby-lang.org/)")).to include %(href="https://www.ruby-lang.org/")
  end

  it "leaves links with an unknown type alone" do
    expect(call("[Other](//unknown/thing)")).to include %(href="//unknown/thing")
  end
end
