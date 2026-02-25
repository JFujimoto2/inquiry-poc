require "rails_helper"

RSpec.describe "Admin::Customers", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:staff) { create(:user, :staff) }

  describe "authorization" do
    it "rejects staff users" do
      sign_in_as(staff)
      get admin_customers_path
      expect(response).to redirect_to(root_path)
    end

    it "rejects unauthenticated users" do
      get admin_customers_path
      expect(response).to redirect_to(new_session_path)
    end
  end

  context "as admin" do
    before { sign_in_as(admin) }

    describe "GET /admin/customers" do
      it "renders the index page" do
        customer = create(:customer, company_name: "Test Corp")
        get admin_customers_path
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Test Corp")
      end

      it "filters by search query" do
        create(:customer, company_name: "Alpha Inc")
        create(:customer, company_name: "Beta LLC")
        get admin_customers_path, params: { q: "Alpha" }
        expect(response.body).to include("Alpha Inc")
        expect(response.body).not_to include("Beta LLC")
      end
    end

    describe "GET /admin/customers/:id" do
      it "renders the show page with inquiry history" do
        customer = create(:customer, company_name: "Show Corp")
        facility = create(:facility)
        create(:inquiry, customer:, facility:)
        get admin_customer_path(customer)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include("Show Corp")
        expect(response.body).to include(facility.name)
      end
    end

    describe "GET /admin/customers/new" do
      it "renders the new form" do
        get new_admin_customer_path
        expect(response).to have_http_status(:ok)
      end
    end

    describe "POST /admin/customers" do
      let(:valid_params) do
        { customer: { company_name: "New Corp", contact_name: "Taro", email: "taro@example.com" } }
      end

      it "creates a customer" do
        expect {
          post admin_customers_path, params: valid_params
        }.to change(Customer, :count).by(1)
        expect(response).to redirect_to(admin_customer_path(Customer.last))
      end

      it "re-renders form on invalid params" do
        post admin_customers_path, params: { customer: { company_name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    describe "PATCH /admin/customers/:id" do
      let(:customer) { create(:customer) }

      it "updates the customer" do
        patch admin_customer_path(customer), params: { customer: { company_name: "Updated Corp" } }
        expect(response).to redirect_to(admin_customer_path(customer))
        expect(customer.reload.company_name).to eq("Updated Corp")
      end
    end

    describe "DELETE /admin/customers/:id" do
      let!(:customer) { create(:customer) }

      it "deletes the customer" do
        expect {
          delete admin_customer_path(customer)
        }.to change(Customer, :count).by(-1)
        expect(response).to redirect_to(admin_customers_path)
      end
    end
  end
end
