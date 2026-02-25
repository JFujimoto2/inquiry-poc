require "rails_helper"

RSpec.describe Aipass::Client do
  let(:client) { described_class.new }
  let(:reservation) { create(:reservation) }
  let(:customer) { create(:customer) }
  let(:facility) { create(:facility) }

  describe "#sync_reservation" do
    it "raises NotImplementedError" do
      expect { client.sync_reservation(reservation) }.to raise_error(NotImplementedError)
    end
  end

  describe "#sync_customer" do
    it "raises NotImplementedError" do
      expect { client.sync_customer(customer) }.to raise_error(NotImplementedError)
    end
  end

  describe "#fetch_cleaning_status" do
    it "raises NotImplementedError" do
      expect { client.fetch_cleaning_status(facility, Date.current) }.to raise_error(NotImplementedError)
    end
  end

  describe "#fetch_sales_data" do
    it "raises NotImplementedError" do
      expect { client.fetch_sales_data(facility, Date.current..Date.current + 7) }.to raise_error(NotImplementedError)
    end
  end
end
