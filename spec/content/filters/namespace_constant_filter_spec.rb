# frozen_string_literal: true

RSpec.describe Site::Content::Filters::NamespaceConstantFilter do
  def call(html)
    described_class.new.call(html)
  end

  def accessor
    %(<span class="punctuation accessor ruby">::</span>)
  end

  it "wraps a bare constant following a :: accessor span" do
    html = "#{accessor}Equalizer"
    expect(call(html)).to eq(%(#{accessor}<span class="support class ruby">Equalizer</span>))
  end

  it "keeps surrounding markup intact" do
    prefix = %(<span class="support class ruby">Core</span>)
    suffix = %(<span class="punctuation ruby">.</span>)
    expect(call("#{prefix}#{accessor}Equalizer#{suffix}")).to eq(
      %(#{prefix}#{accessor}<span class="support class ruby">Equalizer</span>#{suffix})
    )
  end

  it "leaves an already-scoped constant untouched" do
    html = %(#{accessor}<span class="support class ruby">Core</span>)
    expect(call(html)).to eq(html)
  end

  it "ignores a :: that is not inside an accessor span" do
    html = "Dry::Core"
    expect(call(html)).to eq(html)
  end

  it "ignores a :: span without the accessor class" do
    html = %(<span class="punctuation ruby">::</span>Equalizer)
    expect(call(html)).to eq(html)
  end

  it "ignores a lowercase identifier following the accessor" do
    html = "#{accessor}new"
    expect(call(html)).to eq(html)
  end
end
