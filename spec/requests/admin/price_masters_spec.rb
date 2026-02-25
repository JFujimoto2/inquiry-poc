require "rails_helper"

RSpec.describe "Admin::PriceMasters", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:facility) { create(:facility) }

  before { sign_in_as(admin) }

  describe "GET /admin/price_masters" do
    it "renders the index page" do
      get admin_price_masters_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /admin/price_masters" do
    let(:valid_params) do
      { price_master: { facility_id: facility.id, item_type: "lunch", day_type: "weekday", unit_price: 1500 } }
    end

    it "creates a price master" do
      expect {
        post admin_price_masters_path, params: valid_params
      }.to change(PriceMaster, :count).by(1)
    end
  end

  describe "PATCH /admin/price_masters/:id" do
    let(:price_master) { create(:price_master, facility: facility, unit_price: 1000) }
    let(:updated_price) { 2000 }

    it "updates the price master" do
      patch admin_price_master_path(price_master), params: { price_master: { unit_price: updated_price } }
      expect(price_master.reload.unit_price).to eq(updated_price)
    end
  end

  describe "DELETE /admin/price_masters/:id" do
    let!(:price_master) { create(:price_master, facility: facility) }

    it "deletes the price master" do
      expect {
        delete admin_price_master_path(price_master)
      }.to change(PriceMaster, :count).by(-1)
    end
  end
end
