require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user, password: "password123") }

  describe "GET /session/new" do
    it "renders login form" do
      get new_session_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /session" do
    context "with valid credentials" do
      it "logs in and redirects" do
        post session_path, params: { email_address: user.email_address, password: "password123" }
        expect(response).to redirect_to(root_url)
      end
    end

    context "with invalid credentials" do
      it "rejects and redirects to login" do
        post session_path, params: { email_address: user.email_address, password: "wrong" }
        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "DELETE /session" do
    it "logs out and redirects" do
      sign_in_as(user)
      delete session_path
      expect(response).to redirect_to(new_session_path)
    end
  end
end
