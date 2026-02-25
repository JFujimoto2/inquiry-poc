require "rails_helper"

RSpec.describe "Admin::CalendarTypes", type: :request do
  let(:admin) { create(:user, :admin) }

  before { sign_in_as(admin) }

  describe "GET /admin/calendar_types" do
    it "renders the index page" do
      get admin_calendar_types_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/calendar_types" do
    let(:valid_params) do
      { calendar_type: { date: "2026-05-03", day_type: "holiday" } }
    end

    it "creates a calendar type" do
      expect {
        post admin_calendar_types_path, params: valid_params
      }.to change(CalendarType, :count).by(1)
    end
  end

  describe "PATCH /admin/calendar_types/:id" do
    let(:calendar_type) { create(:calendar_type) }

    it "updates the calendar type" do
      patch admin_calendar_type_path(calendar_type), params: { calendar_type: { day_type: "holiday" } }
      expect(calendar_type.reload.day_type).to eq("holiday")
    end
  end

  describe "DELETE /admin/calendar_types/:id" do
    let!(:calendar_type) { create(:calendar_type) }

    it "deletes the calendar type" do
      expect {
        delete admin_calendar_type_path(calendar_type)
      }.to change(CalendarType, :count).by(-1)
    end
  end

  describe "POST /admin/calendar_types/bulk_create" do
    it "creates calendar types for a date range" do
      expect {
        post bulk_create_admin_calendar_types_path, params: {
          start_date: "2026-05-01",
          end_date: "2026-05-03",
          day_type: "holiday"
        }
      }.to change(CalendarType, :count).by(3)
    end
  end
end
