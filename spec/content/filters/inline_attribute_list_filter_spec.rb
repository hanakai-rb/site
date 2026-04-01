# frozen_string_literal: true

RSpec.describe Site::Content::Filters::InlineAttributeListFilter do
  def call(html)
    described_class.call(html)
  end

  it "adds a class to the paragraph" do
    html = "<p>{:.lead} Lead text.</p>"
    expect(call(html)).to eq("<p class=\"lead\">Lead text.</p>")
  end

  it "works when the paragraph contains inline markup after the annotation" do
    html = "<p>{:.lead} <strong>Bold</strong> and normal text.</p>"
    expect(call(html)).to eq("<p class=\"lead\"><strong>Bold</strong> and normal text.</p>")
  end

  it "adds multiple classes from dot-separated notation" do
    html = "<p>{:.lead.large} Text.</p>"
    expect(call(html)).to eq("<p class=\"lead large\">Text.</p>")
  end

  it "merges with existing classes on the element" do
    html = "<p class=\"existing\">{:.lead} Text.</p>"
    expect(call(html)).to eq("<p class=\"existing lead\">Text.</p>")
  end

  it "ignores class names that do not match the safe pattern" do
    html = "<p>{:.valid.1invalid} Text.</p>"
    expect(call(html)).to eq("<p class=\"valid\">Text.</p>")
  end

  it "leaves paragraphs without an annotation untouched" do
    html = "<p>Normal.</p>\n<p>Also normal.</p>"
    expect(call(html)).to eq("<p>Normal.</p>\n<p>Also normal.</p>")
  end

  it "leaves non-paragraph elements untouched" do
    html = "<blockquote><p>A quote.</p></blockquote>"
    expect(call(html)).to eq("<blockquote><p>A quote.</p></blockquote>")
  end
end
