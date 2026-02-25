require "rails_helper"

RSpec.describe "Mypage::ChangeRequests", type: :request do
  let(:customer) { create(:customer) }
  let(:facility) { create(:facility) }
  let(:reservation) { create(:reservation, customer:, facility:) }

  before { sign_in_as_customer(customer) }

  describe "GET /mypage/reservations/:id/change_requests/new" do
    it "renders the new form" do
      get new_mypage_reservation_change_request_path(reservation)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("変更リクエスト")
    end

    it "cannot access another customer's reservation" do
      other_reservation = create(:reservation, customer: create(:customer))
      get new_mypage_reservation_change_request_path(other_reservation)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /mypage/reservations/:id/change_requests" do
    it "creates a change request" do
      expect {
        post mypage_reservation_change_requests_path(reservation),
             params: { change_request: { request_details: "Change check-in date" } }
      }.to change(ChangeRequest, :count).by(1)
      expect(response).to redirect_to(mypage_reservation_path(reservation))
    end

    it "enqueues a notification job" do
      expect {
        post mypage_reservation_change_requests_path(reservation),
             params: { change_request: { request_details: "Change check-in date" } }
      }.to have_enqueued_job(ChangeRequestNotificationJob)
    end

    it "re-renders form on invalid params" do
      post mypage_reservation_change_requests_path(reservation),
           params: { change_request: { request_details: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
