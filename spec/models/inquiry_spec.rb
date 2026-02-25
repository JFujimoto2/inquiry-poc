require "rails_helper"

RSpec.describe Inquiry, type: :model do
  describe "validations" do
    subject { build(:inquiry) }

    it { is_expected.to validate_presence_of(:desired_date) }
    it { is_expected.to validate_presence_of(:num_people) }
    it { is_expected.to validate_numericality_of(:num_people).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:company_name) }
    it { is_expected.to validate_presence_of(:contact_name) }
    it { is_expected.to validate_presence_of(:email) }

    it "validates email format" do
      inquiry = build(:inquiry, email: "invalid")
      expect(inquiry).not_to be_valid
      expect(inquiry.errors[:email]).to be_present
    end

    it "allows valid email" do
      inquiry = build(:inquiry, email: "test@example.com")
      expect(inquiry).to be_valid
    end

    context "breakfast requires accommodation" do
      it "is invalid when breakfast is true but accommodation is false" do
        inquiry = build(:inquiry, breakfast: true, accommodation: false)
        expect(inquiry).not_to be_valid
        expect(inquiry.errors[:breakfast]).to include("requires accommodation to be selected")
      end

      it "is valid when both breakfast and accommodation are true" do
        inquiry = build(:inquiry, breakfast: true, accommodation: true)
        expect(inquiry).to be_valid
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:facility) }
    it { is_expected.to have_one(:quote).dependent(:destroy) }
  end
end
