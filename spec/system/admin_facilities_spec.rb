require "rails_helper"

RSpec.describe "Admin facilities", type: :system do
  let(:admin) { create(:user, :admin) }

  before do
    visit new_session_path
    fill_in "email_address", with: admin.email_address
    fill_in "password", with: "password123"
    click_button "ログイン"
  end

  it "creates a new facility" do
    visit admin_facilities_path

    click_link "新規施設"
    fill_in "施設名", with: "New Test Facility"
    fill_in "送信元メール", with: "info@test.com"
    fill_in "送信元ドメイン", with: "test.com"
    click_button "Create Facility"

    expect(page).to have_content("施設を作成しました")
    expect(page).to have_content("New Test Facility")
  end

  it "edits an existing facility" do
    create(:facility, name: "Existing Facility")
    visit admin_facilities_path

    click_link "編集"
    fill_in "施設名", with: "Updated Facility"
    click_button "Update Facility"

    expect(page).to have_content("施設を更新しました")
  end

  it "deletes a facility" do
    create(:facility, name: "Deletable Facility")
    visit admin_facilities_path

    expect(page).to have_content("Deletable Facility")
    click_button "削除"

    expect(page).to have_content("施設を削除しました")
    expect(page).not_to have_content("Deletable Facility")
  end
end
