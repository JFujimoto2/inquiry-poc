require "rails_helper"

RSpec.describe "Admin::ChangeRequests", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:staff) { create(:user, :staff) }

  describe "authorization" do
    it "rejects staff users" do
      sign_in_as(staff)
      get admin_change_requests_path
      expect(response).to redirect_to(root_path)
    end

    it "rejects unauthenticated users" do
      get admin_change_requests_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  context "as admin" do
    before { sign_in_as(admin) }

    describe "GET /admin/change_requests" do
      it "renders the index page" do
        change_request = create(:change_request)
        get admin_change_requests_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(change_request.customer.company_name)
      end

      it "filters by pending status" do
        pending_cr = create(:change_request, status: ChangeRequest::STATUS_PENDING)
        approved_cr = create(:change_request, :approved)
        get admin_change_requests_path, params: { status: ChangeRequest::STATUS_PENDING }
        expect(response.body).to include(pending_cr.customer.company_name)
      end
    end

    describe "GET /admin/change_requests/:id" do
      it "renders the show page" do
        change_request = create(:change_request)
        get admin_change_request_path(change_request)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(change_request.request_details)
      end

      it "shows respond form for pending requests" do
        change_request = create(:change_request, status: ChangeRequest::STATUS_PENDING)
        get admin_change_request_path(change_request)
        expect(response.body).to include("承認")
        expect(response.body).to include("却下")
      end
    end

    describe "PATCH /admin/change_requests/:id/respond" do
      let(:change_request) { create(:change_request, status: ChangeRequest::STATUS_PENDING) }

      it "approves the change request" do
        patch respond_admin_change_request_path(change_request),
              params: { change_request: { status: ChangeRequest::STATUS_APPROVED, admin_response: "Approved." } }
        expect(change_request.reload.status).to eq(ChangeRequest::STATUS_APPROVED)
        expect(change_request.admin_response).to eq("Approved.")
        expect(response).to redirect_to(admin_change_request_path(change_request))
      end

      it "rejects the change request" do
        patch respond_admin_change_request_path(change_request),
              params: { change_request: { status: ChangeRequest::STATUS_REJECTED, admin_response: "Cannot accommodate." } }
        expect(change_request.reload.status).to eq(ChangeRequest::STATUS_REJECTED)
      end

      it "enqueues customer notification email" do
        expect {
          patch respond_admin_change_request_path(change_request),
                params: { change_request: { status: ChangeRequest::STATUS_APPROVED, admin_response: "Done." } }
        }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
      end
    end
  end
end
