require "rails_helper"

RSpec.describe "Mypage::Dashboard", type: :request do
  let(:customer) { create(:customer) }

  describe "GET /mypage" do
    context "when authenticated" do
      before { sign_in_as_customer(customer) }

      it "renders the dashboard" do
        get mypage_root_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("My Reservations")
      end

      it "shows only own reservations" do
        own_reservation = create(:reservation, customer:, facility: create(:facility))
        other_reservation = create(:reservation, customer: create(:customer))

        get mypage_root_path
        expect(response.body).to include(own_reservation.facility.name)
        expect(response.body).not_to include(other_reservation.facility.name)
      end
    end

    context "when not authenticated" do
      it "redirects to login" do
        get mypage_root_path
        expect(response).to redirect_to(new_mypage_session_path)
      end
    end
  end
end
