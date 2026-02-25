require "rails_helper"

RSpec.describe "Admin facilities", type: :system do
  let(:admin) { create(:user, :admin) }

  before do
    visit new_session_path
    fill_in "email_address", with: admin.email_address
    fill_in "password", with: "password123"
    click_button "Sign in"
  end

  it "creates a new facility" do
    visit admin_facilities_path

    click_link "New Facility"
    fill_in "Name", with: "New Test Facility"
    fill_in "Sender email", with: "info@test.com"
    fill_in "Sender domain", with: "test.com"
    click_button "Create Facility"

    expect(page).to have_content("Facility was successfully created")
    expect(page).to have_content("New Test Facility")
  end

  it "edits an existing facility" do
    create(:facility, name: "Existing Facility")
    visit admin_facilities_path

    click_link "Edit"
    fill_in "Name", with: "Updated Facility"
    click_button "Update Facility"

    expect(page).to have_content("Facility was successfully updated")
  end

  it "deletes a facility" do
    create(:facility, name: "Deletable Facility")
    visit admin_facilities_path

    expect(page).to have_content("Deletable Facility")
    click_button "Delete"

    expect(page).to have_content("Facility was successfully deleted")
    expect(page).not_to have_content("Deletable Facility")
  end
end
