# frozen_string_literal: true

require "nokogiri"

RSpec.describe Site::Content::Filters::MoveHeadingAnchorsFilter do
  def call(html)
    described_class.new.call(html)
  end

  # Compare on structure rather than the serialized string, since Nokogiri
  # introduces insignificant whitespace text nodes that don't affect rendering.
  def heading(html)
    Nokogiri::HTML::DocumentFragment.parse(call(html)).at_css("h1, h2, h3, h4, h5, h6")
  end

  it "moves the heading's anchor link to the end of the heading" do
    h = heading(%(<h2><a href="#title" class="anchor" id="title"></a>Title</h2>))

    expect(h.element_children.last.name).to eq("a")
    expect(h.element_children.last["href"]).to eq("#title")
    expect(h.text.strip).to eq("Title")
  end

  it "relocates the id to the heading so fragment links target the heading itself" do
    h = heading(%(<h2><a href="#title" aria-hidden="true" class="anchor" id="title"></a>Title</h2>))

    # The id (the fragment target) belongs on the heading, so a screen reader
    # following a "#title" link lands on the heading and announces it.
    expect(h["id"]).to eq("title")

    anchor = h.element_children.last
    expect(anchor["id"]).to be_nil
    # The permalink stays decorative and still points at the heading.
    expect(anchor["href"]).to eq("#title")
    expect(anchor["aria-hidden"]).to eq("true")
  end

  it "keeps inline content (including code) before the anchor" do
    h = heading(%(<h2><a href="#via-target" class="anchor" id="via-target"></a>Access via <code>target</code></h2>))

    expect(h.element_children.map(&:name)).to eq(["code", "a"])
    expect(h.element_children.last["class"]).to eq("anchor")
    expect(h.at_css("code").text).to eq("target")
  end

  it "handles multiple headings of different levels" do
    result = call(%(<h2><a href="#a" class="anchor" id="a"></a>A</h2>\n<h3><a href="#b" class="anchor" id="b"></a>B</h3>))
    doc = Nokogiri::HTML::DocumentFragment.parse(result)

    doc.css("h2, h3").each do |h|
      expect(h.element_children.last.name).to eq("a")
    end
    expect(doc.at_css("h2")["id"]).to eq("a")
    expect(doc.at_css("h3")["id"]).to eq("b")
    expect(doc.at_css("h2 a")["href"]).to eq("#a")
    expect(doc.at_css("h3 a")["href"]).to eq("#b")
  end

  it "leaves headings without an anchor untouched" do
    expect(call("<h2>No anchor here</h2>")).to eq("<h2>No anchor here</h2>")
  end

  it "does not move ordinary links within the heading text" do
    h = heading(%(<h2><a href="#title" class="anchor" id="title"></a>See <a href="/docs">docs</a></h2>))

    expect(h.element_children.last["href"]).to eq("#title")
    expect(h.css("a").map { _1["href"] }).to eq(["/docs", "#title"])
  end
end
