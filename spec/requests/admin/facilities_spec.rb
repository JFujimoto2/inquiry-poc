require "rails_helper"

RSpec.describe "Admin::Facilities", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:staff) { create(:user, :staff) }

  describe "authorization" do
    it "rejects staff users" do
      sign_in_as(staff)
      get admin_facilities_path
      expect(response).to redirect_to(root_path)
    end

    it "rejects unauthenticated users" do
      get admin_facilities_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  context "as admin" do
    before { sign_in_as(admin) }

    describe "GET /admin/facilities" do
      it "renders the index page" do
        create(:facility, name: "Test Facility")
        get admin_facilities_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Test Facility")
      end
    end

    describe "GET /admin/facilities/new" do
      it "renders the new form" do
        get new_admin_facility_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /admin/facilities" do
      let(:valid_params) do
        { facility: { name: "New Facility", sender_email: "info@example.com", sender_domain: "example.com" } }
      end

      it "creates a facility" do
        expect {
          post admin_facilities_path, params: valid_params
        }.to change(Facility, :count).by(1)
        expect(response).to redirect_to(admin_facility_path(Facility.last))
      end

      it "re-renders form on invalid params" do
        post admin_facilities_path, params: { facility: { name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "PATCH /admin/facilities/:id" do
      let(:facility) { create(:facility) }

      it "updates the facility" do
        patch admin_facility_path(facility), params: { facility: { name: "Updated Name" } }
        expect(response).to redirect_to(admin_facility_path(facility))
        expect(facility.reload.name).to eq("Updated Name")
      end
    end

    describe "DELETE /admin/facilities/:id" do
      let!(:facility) { create(:facility) }

      it "deletes the facility" do
        expect {
          delete admin_facility_path(facility)
        }.to change(Facility, :count).by(-1)
        expect(response).to redirect_to(admin_facilities_path)
      end
    end
  end
end
