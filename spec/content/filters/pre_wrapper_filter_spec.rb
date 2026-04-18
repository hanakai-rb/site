# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"

RSpec.describe Site::Content::Filters::PreWrapperFilter do
  def call(markdown)
    pipeline = HTMLPipeline.new(
      convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new,
      node_filters: [described_class.new],
      sanitization_config: nil
    )
    pipeline.call(markdown).fetch(:output).to_s
  end

  it "wraps a pre in a div with class 'pre-wrapper' and prepends a button" do
    markdown = <<~MD
      ```ruby
      puts "hi"
      ```
    MD

    output = call(markdown)
    expect(output).to include('<div class="pre-wrapper" data-defo-copy-code>')
    expect(output).to include('<button type="button" class="pre-wrapper__button" aria-label="Copy">')
    expect(output).to include('class="pre-wrapper__icon pre-wrapper__icon--copy"')
    expect(output).to include('class="pre-wrapper__icon pre-wrapper__icon--check"')
    expect(output).to include("</pre></div>")
    expect(output.index("<button")).to be < output.index("<pre")
    expect(output.index("<svg")).to be < output.index("</button>")
  end

  it "does not affect other elements" do
    markdown = "A paragraph."
    expect(call(markdown)).not_to include("<div")
    expect(call(markdown)).not_to include("<button")
  end
end
