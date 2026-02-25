require "rails_helper"

RSpec.describe Customer, type: :model do
  describe "validations" do
    subject { build(:customer) }

    it { is_expected.to validate_presence_of(:company_name) }
    it { is_expected.to validate_presence_of(:contact_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }

    it "validates email format" do
      customer = build(:customer, email: "invalid")
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to be_present
    end

    it "allows valid email" do
      customer = build(:customer, email: "test@example.com")
      expect(customer).to be_valid
    end
  end

  describe "email normalization" do
    it "strips whitespace and downcases email" do
      customer = create(:customer, email: "  TEST@Example.COM  ")
      expect(customer.email).to eq("test@example.com")
    end
  end

  describe "associations" do
    it { is_expected.to have_many(:inquiries).dependent(:nullify) }
    it { is_expected.to have_many(:reservations).dependent(:destroy) }
  end
end
