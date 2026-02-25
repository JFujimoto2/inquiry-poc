require "rails_helper"

RSpec.describe "Admin::EmailTemplates", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:facility) { create(:facility) }

  before { sign_in_as(admin) }

  describe "GET /admin/email_templates" do
    it "renders the index page" do
      get admin_email_templates_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/email_templates" do
    let(:valid_params) do
      { email_template: { facility_id: facility.id, subject: "Quote for {{company_name}}", body: "Dear {{contact_name}}" } }
    end

    it "creates an email template" do
      expect {
        post admin_email_templates_path, params: valid_params
      }.to change(EmailTemplate, :count).by(1)
    end
  end

  describe "PATCH /admin/email_templates/:id" do
    let(:email_template) { create(:email_template, facility: facility) }

    it "updates the email template" do
      patch admin_email_template_path(email_template), params: { email_template: { subject: "Updated Subject" } }
      expect(email_template.reload.subject).to eq("Updated Subject")
    end
  end

  describe "DELETE /admin/email_templates/:id" do
    let!(:email_template) { create(:email_template, facility: facility) }

    it "deletes the email template" do
      expect {
        delete admin_email_template_path(email_template)
      }.to change(EmailTemplate, :count).by(-1)
    end
  end

  describe "GET /admin/email_templates/:id/preview" do
    let(:email_template) { create(:email_template, facility: facility, subject: "Quote for {{company_name}}", body: "Dear {{contact_name}}") }

    it "renders preview with interpolated variables" do
      get preview_admin_email_template_path(email_template)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Quote for サンプル株式会社")
      expect(response.body).to include("Dear サンプル担当者")
    end
  end
end
