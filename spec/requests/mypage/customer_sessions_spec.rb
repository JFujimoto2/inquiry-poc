require "rails_helper"

RSpec.describe "Mypage::CustomerSessions", type: :request do
  describe "GET /mypage/session/new" do
    it "renders the login form" do
      get new_mypage_session_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("マイページログイン")
    end
  end

  describe "POST /mypage/session" do
    let!(:customer) { create(:customer, email: "test@example.com") }

    it "redirects with notice for existing customer" do
      post mypage_session_path, params: { email: "test@example.com" }
      expect(response).to redirect_to(new_mypage_session_path)
      expect(flash[:notice]).to include("ログインリンク")
    end

    it "redirects with same notice for non-existing email" do
      post mypage_session_path, params: { email: "unknown@example.com" }
      expect(response).to redirect_to(new_mypage_session_path)
      expect(flash[:notice]).to include("ログインリンク")
    end
  end

  describe "GET /mypage/session/verify" do
    let(:customer) { create(:customer) }

    context "with valid token" do
      it "creates session and redirects to dashboard" do
        token = CustomerMagicLinkSender.new(customer).call
        get verify_mypage_session_path(token:)
        expect(response).to redirect_to(mypage_root_path)
      end
    end

    context "with expired token" do
      it "redirects to login with error" do
        token = SecureRandom.urlsafe_base64(32)
        customer.customer_sessions.create!(
          token_digest: Digest::SHA256.hexdigest(token),
          expires_at: 1.hour.ago
        )
        get verify_mypage_session_path(token:)
        expect(response).to redirect_to(new_mypage_session_path)
        expect(flash[:alert]).to include("期限切れ")
      end
    end

    context "with invalid token" do
      it "redirects to login with error" do
        get verify_mypage_session_path(token: "invalid_token")
        expect(response).to redirect_to(new_mypage_session_path)
        expect(flash[:alert]).to include("期限切れ")
      end
    end
  end

  describe "DELETE /mypage/session" do
    let(:customer) { create(:customer) }

    it "destroys customer session and redirects to login" do
      sign_in_as_customer(customer)
      delete mypage_session_path
      expect(response).to redirect_to(new_mypage_session_path)
    end
  end
end
