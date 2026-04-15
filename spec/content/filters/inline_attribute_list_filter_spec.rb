# frozen_string_literal: true

RSpec.describe Site::Content::Filters::InlineAttributeListFilter do
  def call(html)
    described_class.new.call(html)
  end

  it "adds a class to the preceding paragraph" do
    html = "<p>Lead text.</p>\n<p>{:.lead}</p>"
    expect(call(html)).to eq("<p class=\"lead\">Lead text.</p>")
  end

  it "works when the preceding paragraph contains inline markup" do
    html = "<p><strong>Bold</strong> and normal text.</p>\n<p>{:.lead}</p>"
    expect(call(html)).to eq("<p class=\"lead\"><strong>Bold</strong> and normal text.</p>")
  end

  it "adds multiple classes from dot-separated notation" do
    html = "<p>Text.</p>\n<p>{:.lead.large}</p>"
    expect(call(html)).to eq("<p class=\"lead large\">Text.</p>")
  end

  it "merges with existing classes on the preceding element" do
    html = "<p class=\"existing\">Text.</p>\n<p>{:.lead}</p>"
    expect(call(html)).to eq("<p class=\"existing lead\">Text.</p>")
  end

  it "ignores class names that do not match the safe pattern" do
    html = "<p>Text.</p>\n<p>{:.valid.1invalid}</p>"
    expect(call(html)).to eq("<p class=\"valid\">Text.</p>")
  end

  it "leaves paragraphs without a following annotation untouched" do
    html = "<p>Normal.</p>\n<p>Also normal.</p>"
    expect(call(html)).to eq("<p>Normal.</p>\n<p>Also normal.</p>")
  end

  it "leaves non-paragraph elements untouched" do
    html = "<blockquote><p>A quote.</p></blockquote>"
    expect(call(html)).to eq("<blockquote><p>A quote.</p></blockquote>")
  end

  it "works when annotation follows a non-paragraph block element" do
    html = "<h2>Heading</h2>\n<p>{:.lead}</p>"
    expect(call(html)).to eq("<h2 class=\"lead\">Heading</h2>")
  end
end
