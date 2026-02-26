require "rails_helper"

RSpec.describe QuoteCalculator do
  let(:facility) { create(:facility) }

  def create_price(item_type, day_type, price)
    create(:price_master, facility: facility, item_type: item_type, day_type: day_type, unit_price: price)
  end

  describe "#calculate" do
    context "single day weekday: conference_room + lunch" do
      let(:conference_room_price) { 5_000 }
      let(:lunch_price) { 1_500 }
      let(:num_people) { 10 }
      let(:expected_total) { (conference_room_price + lunch_price) * num_people }

      before do
        create_price("conference_room", "weekday", conference_room_price)
        create_price("lunch", "weekday", lunch_price)
      end

      let(:inquiry) do
        build(:inquiry, facility: facility, desired_date: Date.new(2026, 4, 1),
              desired_end_date: Date.new(2026, 4, 1),
              num_people: num_people, conference_room: true, lunch: true,
              accommodation: false, breakfast: false, dinner: false)
      end

      it "calculates the correct total" do
        result = described_class.new(inquiry).calculate
        expect(result.total).to eq(expected_total)
      end

      it "returns correct line items" do
        result = described_class.new(inquiry).calculate
        expect(result.line_items.size).to eq(2)
        expect(result.line_items.map(&:item_type)).to contain_exactly("conference_room", "lunch")
      end

      it "includes date in line items" do
        result = described_class.new(inquiry).calculate
        expect(result.line_items.first.date).to eq(Date.new(2026, 4, 1))
      end
    end

    context "multi-day: 3 days with mixed day types" do
      let(:conference_room_weekday_price) { 5_000 }
      let(:conference_room_holiday_price) { 8_000 }
      let(:num_people) { 10 }

      before do
        create_price("conference_room", "weekday", conference_room_weekday_price)
        create_price("conference_room", "holiday", conference_room_holiday_price)
        create(:calendar_type, date: Date.new(2026, 5, 3), day_type: "holiday")
      end

      let(:inquiry) do
        build(:inquiry, facility: facility,
              desired_date: Date.new(2026, 5, 1),
              desired_end_date: Date.new(2026, 5, 3),
              num_people: num_people, conference_room: true,
              accommodation: false, breakfast: false, lunch: false, dinner: false)
      end

      it "calculates per-day pricing" do
        result = described_class.new(inquiry).calculate
        expect(result.line_items.size).to eq(3)
      end

      it "applies correct day_type per date" do
        result = described_class.new(inquiry).calculate
        day_types = result.line_items.map { |li| [li.date, li.day_type] }
        expect(day_types).to include([Date.new(2026, 5, 1), "weekday"])
        expect(day_types).to include([Date.new(2026, 5, 2), "weekday"])
        expect(day_types).to include([Date.new(2026, 5, 3), "holiday"])
      end

      it "calculates correct total for mixed days" do
        result = described_class.new(inquiry).calculate
        expected = (conference_room_weekday_price * 2 + conference_room_holiday_price) * num_people
        expect(result.total).to eq(expected)
      end
    end

    context "holiday: accommodation" do
      let(:holiday_date) { Date.new(2026, 5, 3) }
      let(:accommodation_price) { 12_000 }
      let(:num_people) { 5 }
      let(:expected_total) { accommodation_price * num_people }

      before do
        create(:calendar_type, date: holiday_date, day_type: "holiday")
        create_price("accommodation", "holiday", accommodation_price)
      end

      let(:inquiry) do
        build(:inquiry, facility: facility, desired_date: holiday_date,
              desired_end_date: holiday_date,
              num_people: num_people, accommodation: true,
              conference_room: false, breakfast: false, lunch: false, dinner: false)
      end

      it "applies holiday pricing" do
        result = described_class.new(inquiry).calculate
        expect(result.total).to eq(expected_total)
        expect(result.line_items.first.day_type).to eq("holiday")
      end
    end

    context "unregistered date defaults to weekday" do
      let(:conference_room_price) { 5_000 }
      let(:num_people) { 3 }
      let(:expected_total) { conference_room_price * num_people }

      before do
        create_price("conference_room", "weekday", conference_room_price)
      end

      let(:inquiry) do
        build(:inquiry, facility: facility, desired_date: Date.new(2026, 7, 15),
              desired_end_date: Date.new(2026, 7, 15),
              num_people: num_people, conference_room: true,
              accommodation: false, breakfast: false, lunch: false, dinner: false)
      end

      it "uses weekday pricing" do
        result = described_class.new(inquiry).calculate
        expect(result.total).to eq(expected_total)
        expect(result.line_items.first.day_type).to eq("weekday")
      end
    end

    context "no items selected" do
      let(:inquiry) do
        build(:inquiry, facility: facility,
              conference_room: false, accommodation: false,
              breakfast: false, lunch: false, dinner: false)
      end

      it "returns zero total" do
        result = described_class.new(inquiry).calculate
        expect(result.total).to eq(0)
        expect(result.line_items).to be_empty
      end
    end

    context "price master not found" do
      let(:inquiry) do
        build(:inquiry, facility: facility, conference_room: true,
              accommodation: false, breakfast: false, lunch: false, dinner: false)
      end

      it "raises PriceNotFoundError" do
        expect {
          described_class.new(inquiry).calculate
        }.to raise_error(QuoteCalculator::PriceNotFoundError)
      end
    end
  end
end
