require "rails_helper"

RSpec.describe "Security", type: :request do
  describe "unauthenticated admin access" do
    it "redirects to login for admin dashboard" do
      get admin_root_path
      expect(response).to redirect_to(new_session_path)
    end

    it "redirects to login for admin facilities" do
      get admin_facilities_path
      expect(response).to redirect_to(new_session_path)
    end

    it "redirects to login for admin price masters" do
      get admin_price_masters_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe "staff role cannot access admin" do
    let(:staff) { create(:user, :staff) }

    before { sign_in_as(staff) }

    it "rejects staff from admin dashboard" do
      get admin_root_path
      expect(response).to redirect_to(root_path)
    end

    it "rejects staff from admin facilities" do
      get admin_facilities_path
      expect(response).to redirect_to(root_path)
    end

    it "rejects staff from admin price masters" do
      get admin_price_masters_path
      expect(response).to redirect_to(root_path)
    end
  end

  describe "CSRF protection" do
    it "is configured on the application controller" do
      expect(ApplicationController.ancestors).to include(ActionController::RequestForgeryProtection)
      # Verify forgery protection callback is registered
      callbacks = ApplicationController._process_action_callbacks.map(&:filter)
      expect(callbacks).to include(:verify_authenticity_token)
    end
  end
end
