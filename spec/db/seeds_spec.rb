require "rails_helper"

RSpec.describe "db/seeds.rb" do
  it "runs without error" do
    expect { Rails.application.load_seed }.not_to raise_error
  end

  it "creates at least 2 facilities" do
    Rails.application.load_seed
    expect(Facility.count).to be >= 2
  end

  it "creates price masters for all item_type/day_type combinations per facility" do
    Rails.application.load_seed
    expected_count = PriceMaster::ITEM_TYPES.size * CalendarType::DAY_TYPES.size

    Facility.find_each do |facility|
      expect(facility.price_masters.count).to eq(expected_count)
    end
  end

  it "creates email templates for all facilities" do
    Rails.application.load_seed
    Facility.find_each do |facility|
      expect(facility.email_template).to be_present
    end
  end
end
