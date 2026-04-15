# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"

RSpec.describe Site::Content::Filters::TableWrapperFilter do
  def call(markdown)
    pipeline = HTMLPipeline.new(
      convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new,
      node_filters: [described_class.new],
      sanitization_config: nil
    )
    pipeline.call(markdown).fetch(:output).to_s
  end

  it "wraps a table in a div with class 'table'" do
    markdown = <<~MD
      | A | B |
      |---|---|
      | 1 | 2 |
    MD

    expect(call(markdown)).to include('class="table-wrapper"')
    expect(call(markdown)).to include('data-defo-overflow-class=')
    expect(call(markdown)).to include("</table></div>")
  end

  it "does not affect other elements" do
    markdown = "A paragraph."
    expect(call(markdown)).not_to include("<div")
  end
end
