# frozen_string_literal: true

RSpec.describe Site::Content::Filters::InlineAttributeListFilter do
  def call(html)
    described_class.call(html)
  end

  it "adds a class to the preceding paragraph" do
    html = "<p>Lead text.</p>\n<p>{:.lead}</p>"
    expect(call(html)).to eq("<p class=\"lead\">Lead text.</p>\n")
  end

  it "adds a class to the preceding blockquote" do
    html = "<blockquote><p>A quote.</p></blockquote>\n<p>{:.callout}</p>"
    expect(call(html)).to eq("<blockquote class=\"callout\"><p>A quote.</p></blockquote>\n")
  end

  it "adds multiple classes from dot-separated notation" do
    html = "<p>Text.</p>\n<p>{:.lead.large}</p>"
    expect(call(html)).to eq("<p class=\"lead large\">Text.</p>\n")
  end

  it "merges with existing classes on the target element" do
    html = "<p class=\"existing\">Text.</p>\n<p>{:.lead}</p>"
    expect(call(html)).to eq("<p class=\"existing lead\">Text.</p>\n")
  end

  it "silently strips the annotation when there is no preceding sibling" do
    html = "<p>{:.lead}</p>\n<p>Normal.</p>"
    expect(call(html)).to eq("\n<p>Normal.</p>")
  end

  it "ignores class names that do not match the safe pattern" do
    html = "<p>Text.</p>\n<p>{:.valid.1invalid}</p>"
    expect(call(html)).to eq("<p class=\"valid\">Text.</p>\n")
  end

  it "leaves unrelated paragraphs untouched" do
    html = "<p>Normal.</p>\n<p>Also normal.</p>"
    expect(call(html)).to eq("<p>Normal.</p>\n<p>Also normal.</p>")
  end
end
