# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"

RSpec.describe Site::Content::Pipeline do
  let(:base_pipeline) do
    HTMLPipeline.new(
      convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new,
      sanitization_config: nil
    )
  end

  it "applies post_filters to the output after the pipeline runs" do
    upcaser = ->(html) { html.upcase }

    pipeline = described_class.new(base_pipeline, post_filters: [upcaser])
    result = pipeline.call("hello")

    expect(result.fetch(:output).to_s).to eq("<P>HELLO</P>")
  end

  it "applies multiple post_filters in order" do
    append_a = ->(html) { html + "A" }
    append_b = ->(html) { html + "B" }

    pipeline = described_class.new(base_pipeline, post_filters: [append_a, append_b])
    result = pipeline.call("x")

    expect(result.fetch(:output).to_s).to end_with("AB")
  end

  it "passes context and result through to the underlying pipeline" do
    recorder = Class.new(HTMLPipeline::NodeFilter) do
      SELECTOR = Selma::Selector.new(match_element: "p")
      def selector = SELECTOR
      def handle_element(_element)
        result[:seen] = true
      end
    end

    pipeline_with_filter = HTMLPipeline.new(
      convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new,
      node_filters: [recorder.new],
      sanitization_config: nil
    )
    pipeline = described_class.new(pipeline_with_filter)
    result = pipeline.call("hello")

    expect(result[:seen]).to be true
  end

  it "works with no post_filters" do
    pipeline = described_class.new(base_pipeline)
    result = pipeline.call("hello")

    expect(result.fetch(:output).to_s).to eq("<p>hello</p>")
  end
end
