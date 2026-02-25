require "rails_helper"

RSpec.describe "Admin::Reservations", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:staff) { create(:user, :staff) }

  describe "authorization" do
    it "rejects staff users" do
      sign_in_as(staff)
      get admin_reservations_path
      expect(response).to redirect_to(root_path)
    end

    it "rejects unauthenticated users" do
      get admin_reservations_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  context "as admin" do
    before { sign_in_as(admin) }

    describe "GET /admin/reservations" do
      it "renders the index page" do
        reservation = create(:reservation)
        get admin_reservations_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(reservation.facility.name)
      end

      it "filters by status" do
        confirmed = create(:reservation, :confirmed)
        pending = create(:reservation, status: "pending_confirmation")
        get admin_reservations_path, params: { status: "confirmed" }
        expect(response.body).to include(confirmed.facility.name)
        expect(response.body).not_to include(pending.customer.company_name)
      end
    end

    describe "GET /admin/reservations/:id" do
      it "renders the show page with transition buttons" do
        reservation = create(:reservation, status: "pending_confirmation")
        get admin_reservation_path(reservation)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Confirmed")
        expect(response.body).to include("Cancelled")
      end
    end

    describe "POST /admin/reservations (from inquiry)" do
      let(:facility) { create(:facility) }
      let(:inquiry) { create(:inquiry, facility:, email: "test@example.com") }

      it "creates a reservation from an inquiry" do
        expect {
          post admin_reservations_path, params: { inquiry_id: inquiry.id }
        }.to change(Reservation, :count).by(1)
        expect(response).to redirect_to(admin_reservation_path(Reservation.last))
      end
    end

    describe "PATCH /admin/reservations/:id" do
      let(:reservation) { create(:reservation) }

      it "updates the reservation" do
        patch admin_reservation_path(reservation), params: { reservation: { admin_notes: "Updated notes" } }
        expect(response).to redirect_to(admin_reservation_path(reservation))
        expect(reservation.reload.admin_notes).to eq("Updated notes")
      end
    end

    describe "PATCH /admin/reservations/:id/transition" do
      let(:reservation) { create(:reservation, status: "pending_confirmation") }

      it "transitions reservation status" do
        patch transition_admin_reservation_path(reservation), params: { status: "confirmed" }
        expect(response).to redirect_to(admin_reservation_path(reservation))
        expect(reservation.reload.status).to eq("confirmed")
      end

      it "shows error for invalid transition" do
        reservation.update!(status: "checked_out")
        patch transition_admin_reservation_path(reservation), params: { status: "confirmed" }
        expect(response).to redirect_to(admin_reservation_path(reservation))
        expect(flash[:alert]).to be_present
      end
    end

    describe "DELETE /admin/reservations/:id" do
      let!(:reservation) { create(:reservation) }

      it "deletes the reservation" do
        expect {
          delete admin_reservation_path(reservation)
        }.to change(Reservation, :count).by(-1)
        expect(response).to redirect_to(admin_reservations_path)
      end
    end
  end
end
