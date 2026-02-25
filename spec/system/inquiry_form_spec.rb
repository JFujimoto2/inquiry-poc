require "rails_helper"

RSpec.describe "Inquiry form", type: :system do
  let(:facility) { create(:facility, name: "Test Resort") }
  let(:conference_room_price) { 5_000 }
  let(:lunch_price) { 1_500 }

  before do
    create(:price_master, facility: facility, item_type: "conference_room", day_type: "weekday", unit_price: conference_room_price)
    create(:price_master, facility: facility, item_type: "lunch", day_type: "weekday", unit_price: lunch_price)
    create(:email_template, facility: facility)
  end

  it "submits inquiry and shows thank you page" do
    visit new_inquiry_path

    select "Test Resort", from: "Facility"
    fill_in "Desired date", with: "2026-04-01"
    fill_in "Number of People", with: "10"
    check "Conference Room"
    check "Lunch"
    fill_in "Company name", with: "Test Corp"
    fill_in "Contact name", with: "Taro Yamada"
    fill_in "Email", with: "taro@example.com"

    click_button "Submit Inquiry"

    expect(page).to have_content("Thank You")
  end

  it "shows validation errors" do
    visit new_inquiry_path

    click_button "Submit Inquiry"

    expect(page).to have_content("can't be blank")
  end
end
