# frozen_string_literal: true

RSpec.describe Site::Content::Filters::EmojiLogoFilter do
  def call(html)
    described_class.new.call(html)
  end

  it "replaces 🌸 with the Hanami logo SVG" do
    output = call("<p>Happy coding! 🌸</p>")
    expect(output).to include("Happy coding! ")
    expect(output).to include('class="emoji-logo emoji-logo--hanami inline"')
    expect(output).not_to include("🌸")
  end

  it "replaces the :hanami: shortcode with the Hanami logo SVG" do
    output = call("<p>Welcome to :hanami:.</p>")
    expect(output).to include('class="emoji-logo emoji-logo--hanami inline"')
    expect(output).not_to include(":hanami:")
  end

  it "replaces the :hanakai: shortcode with the Hanakai logo SVG" do
    output = call("<p>See :hanakai:.</p>")
    expect(output).to include('class="emoji-logo emoji-logo--hanakai inline"')
    expect(output).not_to include(":hanakai:")
  end

  it "replaces the :rom: shortcode with the ROM logo SVG" do
    output = call("<p>Backed by :rom:.</p>")
    expect(output).to include('class="emoji-logo emoji-logo--rom inline"')
    expect(output).not_to include(":rom:")
  end

  it "replaces the :dry: shortcode with the Dry logo SVG" do
    output = call("<p>Powered by :dry:.</p>")
    expect(output).to include('class="emoji-logo emoji-logo--dry inline"')
    expect(output).not_to include(":dry:")
  end

  it "replaces a mix of shortcodes and emoji in the same text" do
    output = call("<p>:hanami: + :rom: + :dry: 🌸</p>")
    expect(output.scan("<svg").length).to eq(4)
    expect(output.scan("emoji-logo--hanami").length).to eq(2)
    expect(output.scan("emoji-logo--rom").length).to eq(1)
    expect(output.scan("emoji-logo--dry").length).to eq(1)
  end

  it "replaces repeated 🌸 in the same text node" do
    output = call("<p>🌸🌸🌸</p>")
    expect(output.scan("<svg").length).to eq(3)
    expect(output).not_to include("🌸")
  end

  it "replaces shortcodes across different elements" do
    output = call("<h2>:hanami: Heading</h2><p>And 🌸 again.</p>")
    expect(output.scan("<svg").length).to eq(2)
  end

  it "leaves shortcodes inside a code block untouched" do
    output = call("<pre><code>puts \":hanami:\"</code></pre>")
    expect(output).to include(":hanami:")
    expect(output).not_to include("<svg")
  end

  it "leaves shortcodes inside inline code untouched" do
    output = call("<p>Use <code>:dry:</code> as a shortcode.</p>")
    expect(output).to include("<code>:dry:</code>")
    expect(output).not_to include("<svg")
  end

  it "replaces a shortcode alongside inline code" do
    output = call("<p>The <code>flag</code> :rom: please.</p>")
    expect(output).to include("<code>flag</code>")
    expect(output).to include('class="emoji-logo emoji-logo--rom inline"')
    expect(output).not_to include(":rom:")
  end

  it "leaves html without any trigger unchanged" do
    html = "<p>No flowers here.</p>"
    expect(call(html)).to eq(html)
  end

  it "preserves surrounding text including characters that need HTML escaping" do
    output = call("<p>5 < 10 🌸 yes</p>")
    expect(output).to include("5 &lt; 10 ")
    expect(output).to include("<svg")
  end
end
