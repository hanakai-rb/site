# frozen_string_literal: true

RSpec.describe Site::Sponsors::OpenCollective do
  subject(:source) {
    described_class.new(slug: "hanami", one_time_window_months: 3, now: Time.utc(2026, 10, 1))
  }

  before do
    allow(source).to receive(:request).and_return(
      "account" => {"orders" => {"totalCount" => orders.length, "nodes" => orders}}
    )
  end

  def order(slug, frequency:, status:, created_at:)
    {
      "createdAt" => created_at,
      "frequency" => frequency,
      "status" => status,
      "fromAccount" => {"slug" => slug, "name" => slug, "imageUrl" => "https://example.com/#{slug}.png"}
    }
  end

  def handles
    source.call.sponsors.map { it.fetch("handle") }
  end

  describe "one-time donations" do
    let(:orders) {
      [
        order("recent", frequency: "ONETIME", status: "PAID", created_at: "2026-07-02T00:00:00Z"),
        order("lapsed", frequency: "ONETIME", status: "PAID", created_at: "2026-06-30T00:00:00Z")
      ]
    }

    it "keeps donors from the last 3 months, and drops older ones" do
      expect(handles).to eq ["recent"]
    end
  end

  describe "recurring donations" do
    let(:orders) {
      [
        order("active", frequency: "MONTHLY", status: "ACTIVE", created_at: "2024-01-01T00:00:00Z"),
        order("stopped", frequency: "MONTHLY", status: "PAID", created_at: "2026-09-01T00:00:00Z")
      ]
    }

    it "keeps active ones however old they are, and drops ones that have stopped" do
      expect(handles).to eq ["active"]
    end
  end

  describe "anonymous donors" do
    let(:orders) {
      [
        order("guest-1a2b", frequency: "ONETIME", status: "PAID", created_at: "2026-09-01T00:00:00Z"),
        order("incognito-3c4d", frequency: "MONTHLY", status: "ACTIVE", created_at: "2026-09-01T00:00:00Z")
      ]
    }

    it "counts them without naming them" do
      listing = source.call

      expect(listing.sponsors).to be_empty
      expect(listing.private_count).to eq 2
    end
  end
end
