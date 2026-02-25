require "rails_helper"

RSpec.describe QuotePdfGenerator do
  let(:facility) { create(:facility, name: "Test Resort") }
  let(:conference_room_price) { 5_000 }
  let(:lunch_price) { 1_500 }
  let(:num_people) { 10 }

  let(:inquiry) do
    create(:inquiry,
      facility: facility,
      company_name: "Acme Corp",
      contact_name: "Test User",
      desired_date: Date.new(2026, 4, 1),
      num_people: num_people,
      conference_room: true,
      lunch: true,
      total_amount: (conference_room_price + lunch_price) * num_people
    )
  end

  let(:quote) { create(:quote, inquiry: inquiry) }

  before do
    create(:price_master, facility: facility, item_type: "conference_room", day_type: "weekday", unit_price: conference_room_price)
    create(:price_master, facility: facility, item_type: "lunch", day_type: "weekday", unit_price: lunch_price)
  end

  describe "#generate" do
    let(:pdf_data) { described_class.new(quote).generate }

    it "generates valid PDF binary" do
      expect(pdf_data).to start_with("%PDF")
    end

    it "contains company name" do
      reader = PDF::Reader.new(StringIO.new(pdf_data))
      text = reader.pages.map(&:text).join
      expect(text).to include("Acme Corp")
    end

    it "contains facility name" do
      reader = PDF::Reader.new(StringIO.new(pdf_data))
      text = reader.pages.map(&:text).join
      expect(text).to include("Test Resort")
    end

    it "contains line item details" do
      reader = PDF::Reader.new(StringIO.new(pdf_data))
      text = reader.pages.map(&:text).join
      expect(text).to include("Conference Room")
      expect(text).to include("Lunch")
    end

    it "contains total amount" do
      expected_total = (conference_room_price + lunch_price) * num_people
      reader = PDF::Reader.new(StringIO.new(pdf_data))
      text = reader.pages.map(&:text).join
      expect(text).to include(expected_total.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse)
    end
  end
end
