require "rails_helper"

RSpec.describe "Admin::Inquiries", type: :request do
  let(:admin) { create(:user, :admin) }

  before { sign_in_as(admin) }

  describe "GET /admin/inquiries" do
    it "renders the index page" do
      inquiry = create(:inquiry)
      get admin_inquiries_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(inquiry.company_name)
    end

    it "shows create reservation link for inquiries without reservation" do
      inquiry = create(:inquiry)
      get admin_inquiries_path
      expect(response.body).to include("Create Reservation")
    end
  end

  describe "GET /admin/inquiries/:id" do
    it "renders the show page" do
      inquiry = create(:inquiry)
      get admin_inquiry_path(inquiry)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(inquiry.company_name)
    end

    it "shows create reservation button when no reservation exists" do
      inquiry = create(:inquiry)
      get admin_inquiry_path(inquiry)
      expect(response.body).to include("Create Reservation")
    end

    it "shows view reservation link when reservation exists" do
      reservation = create(:reservation)
      get admin_inquiry_path(reservation.inquiry)
      expect(response.body).to include("View Reservation")
    end
  end
end
