require "rails_helper"

RSpec.describe CalendarType, type: :model do
  describe "validations" do
    subject { build(:calendar_type) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_uniqueness_of(:date) }
    it { is_expected.to validate_presence_of(:day_type) }
    it { is_expected.to validate_inclusion_of(:day_type).in_array(CalendarType::DAY_TYPES) }
  end

  describe ".day_type_for" do
    it "returns the day type for a registered date" do
      create(:calendar_type, date: Date.new(2026, 5, 3), day_type: "holiday")
      expect(CalendarType.day_type_for(Date.new(2026, 5, 3))).to eq("holiday")
    end

    it "returns weekday for an unregistered date" do
      expect(CalendarType.day_type_for(Date.new(2026, 6, 15))).to eq("weekday")
    end
  end
end
