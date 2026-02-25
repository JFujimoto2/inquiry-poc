require "rails_helper"

RSpec.describe "Mypage::Reservations", type: :request do
  let(:customer) { create(:customer) }
  let(:facility) { create(:facility) }
  let(:reservation) { create(:reservation, customer:, facility:) }

  describe "GET /mypage/reservations/:id" do
    context "when authenticated" do
      before { sign_in_as_customer(customer) }

      it "renders the reservation detail" do
        get mypage_reservation_path(reservation)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(facility.name)
      end

      it "cannot access another customer's reservation" do
        other_reservation = create(:reservation, customer: create(:customer))
        get mypage_reservation_path(other_reservation)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get mypage_reservation_path(reservation)
        expect(response).to redirect_to(new_mypage_session_path)
      end
    end
  end
end
