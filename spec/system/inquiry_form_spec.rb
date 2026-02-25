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

    select "Test Resort", from: "施設"
    fill_in "利用希望日", with: "2026-04-01"
    fill_in "利用人数", with: "10"
    check "会議室"
    check "昼食"
    fill_in "会社名", with: "Test Corp"
    fill_in "担当者名", with: "Taro Yamada"
    fill_in "メールアドレス", with: "taro@example.com"

    click_button "問い合わせを送信"

    expect(page).to have_content("お問い合わせありがとうございます")
  end

  it "shows validation errors" do
    visit new_inquiry_path

    click_button "問い合わせを送信"

    expect(page).to have_content("can't be blank")
  end
end
