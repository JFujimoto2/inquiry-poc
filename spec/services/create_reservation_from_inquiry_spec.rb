require "rails_helper"

RSpec.describe CreateReservationFromInquiry do
  let(:facility) { create(:facility) }
  let(:inquiry) do
    create(:inquiry,
      facility:,
      company_name: "Acme Corp",
      contact_name: "Taro Yamada",
      email: "taro@acme.com",
      desired_date: Date.new(2026, 5, 1),
      num_people: 5,
      total_amount: 25_000
    )
  end

  describe "#call" do
    context "when customer does not exist" do
      it "creates a new customer" do
        expect { described_class.new(inquiry).call }
          .to change(Customer, :count).by(1)
      end

      it "creates customer with inquiry data" do
        described_class.new(inquiry).call
        customer = Customer.find_by(email: "taro@acme.com")
        expect(customer.company_name).to eq("Acme Corp")
        expect(customer.contact_name).to eq("Taro Yamada")
      end
    end

    context "when customer already exists" do
      let!(:existing_customer) { create(:customer, email: "taro@acme.com", company_name: "Old Corp") }

      it "reuses existing customer" do
        expect { described_class.new(inquiry).call }
          .not_to change(Customer, :count)
      end

      it "links existing customer to inquiry" do
        described_class.new(inquiry).call
        expect(inquiry.reload.customer).to eq(existing_customer)
      end
    end

    it "links customer to inquiry" do
      described_class.new(inquiry).call
      expect(inquiry.reload.customer).to be_present
    end

    it "creates a reservation with pending_confirmation status" do
      reservation = described_class.new(inquiry).call
      expect(reservation.status).to eq("pending_confirmation")
    end

    it "maps inquiry attributes to reservation" do
      reservation = described_class.new(inquiry).call
      expect(reservation.facility).to eq(facility)
      expect(reservation.check_in_date).to eq(Date.new(2026, 5, 1))
      expect(reservation.num_people).to eq(5)
      expect(reservation.total_amount).to eq(25_000)
    end
  end
end
