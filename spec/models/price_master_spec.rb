require "rails_helper"

RSpec.describe PriceMaster, type: :model do
  describe "validations" do
    subject { build(:price_master) }

    it { is_expected.to validate_presence_of(:item_type) }
    it { is_expected.to validate_inclusion_of(:item_type).in_array(PriceMaster::ITEM_TYPES) }
    it { is_expected.to validate_presence_of(:day_type) }
    it { is_expected.to validate_inclusion_of(:day_type).in_array(PriceMaster::DAY_TYPES) }
    it { is_expected.to validate_presence_of(:unit_price) }
    it { is_expected.to validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_uniqueness_of(:item_type).scoped_to(:facility_id, :day_type) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:facility) }
  end

  describe ".price_for" do
    let(:facility) { create(:facility) }

    it "returns the unit price for a matching record" do
      create(:price_master, facility: facility, item_type: "lunch", day_type: "weekday", unit_price: 1500)
      expect(PriceMaster.price_for(facility, "lunch", "weekday")).to eq(1500)
    end

    it "raises RecordNotFound when no matching record exists" do
      expect {
        PriceMaster.price_for(facility, "lunch", "holiday")
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
