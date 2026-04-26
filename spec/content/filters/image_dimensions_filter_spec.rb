# frozen_string_literal: true

require "html_pipeline"
require "html_pipeline/convert_filter/markdown_filter"

RSpec.describe Site::Content::Filters::ImageDimensionsFilter do
  let(:fixtures_dir) { File.expand_path("../../fixtures/images", __dir__) }

  def call(markdown, context: {source_dir: fixtures_dir})
    pipeline = HTMLPipeline.new(
      convert_filter: HTMLPipeline::ConvertFilter::MarkdownFilter.new(
        context: {markdown: {render: {unsafe: true}}}
      ),
      node_filters: [described_class.new],
      sanitization_config: nil
    )
    pipeline.call(markdown, context: context).fetch(:output).to_s
  end

  it "adds width and height to a //file/ image" do
    output = call("![Sample](//file/sample.png)")
    expect(output).to include('width="16"')
    expect(output).to include('height="10"')
  end

  it "supports webp" do
    output = call("![Sample](//file/sample.webp)")
    expect(output).to include('width="64"')
    expect(output).to include('height="32"')
  end

  it "leaves images that already have width and height untouched" do
    output = call('<img src="//file/sample.png" width="100" height="50">')
    expect(output).to include('width="100"')
    expect(output).to include('height="50"')
    expect(output).not_to include('width="16"')
  end

  it "skips external URLs" do
    output = call("![Cat](https://example.com/cat.png)")
    expect(output).not_to include("width=")
    expect(output).not_to include("height=")
  end

  it "skips //file/ URLs that don't resolve to a real file" do
    output = call("![Missing](//file/does-not-exist.png)")
    expect(output).not_to include("width=")
    expect(output).not_to include("height=")
  end

  it "does nothing when source_dir context is missing" do
    output = call("![Sample](//file/sample.png)", context: {})
    expect(output).not_to include("width=")
    expect(output).not_to include("height=")
  end

  describe "with :image_paths context (absolute URLs)" do
    let(:sample_path) { File.join(fixtures_dir, "sample.png") }
    let(:image_paths) { {"/blog/assets/some-post/sample.png" => sample_path} }

    it "resolves absolute URLs via the paths map" do
      output = call(
        "![Sample](/blog/assets/some-post/sample.png)",
        context: {image_paths: image_paths}
      )
      expect(output).to include('width="16"')
      expect(output).to include('height="10"')
    end

    it "skips URLs not in the paths map" do
      output = call(
        "![Missing](/blog/assets/some-post/missing.png)",
        context: {image_paths: image_paths}
      )
      expect(output).not_to include("width=")
    end

    it "skips external URLs even when paths map is provided" do
      output = call(
        "![Cat](https://example.com/cat.png)",
        context: {image_paths: image_paths}
      )
      expect(output).not_to include("width=")
    end
  end
end
