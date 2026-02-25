require "rails_helper"

RSpec.describe Aipass::MockClient do
  let(:client) { described_class.new }
  let(:reservation) { create(:reservation) }
  let(:customer) { create(:customer) }
  let(:facility) { create(:facility) }

  describe "#sync_reservation" do
    it "returns a successful response" do
      response = client.sync_reservation(reservation)
      expect(response).to be_success
      expect(response.data[:external_id]).to eq("#{described_class::MOCK_RESERVATION_PREFIX}-#{reservation.id}")
    end
  end

  describe "#sync_customer" do
    it "returns a successful response" do
      response = client.sync_customer(customer)
      expect(response).to be_success
      expect(response.data[:external_id]).to eq("#{described_class::MOCK_CUSTOMER_PREFIX}-#{customer.id}")
    end
  end

  describe "#fetch_cleaning_status" do
    it "returns cleaning status data" do
      response = client.fetch_cleaning_status(facility, Date.current)
      expect(response).to be_success
      expect(response.data[:status]).to eq(described_class::MOCK_CLEANING_STATUS)
    end
  end

  describe "#fetch_sales_data" do
    it "returns sales data" do
      date_range = Date.current..Date.current + 7
      response = client.fetch_sales_data(facility, date_range)
      expect(response).to be_success
      expect(response.data[:total_revenue]).to eq(described_class::MOCK_TOTAL_REVENUE)
    end
  end
end
