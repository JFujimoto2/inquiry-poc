require "rails_helper"

RSpec.describe Inquiry, type: :model do
  describe "validations" do
    subject { build(:inquiry) }

    it { is_expected.to validate_presence_of(:desired_date) }
    it { is_expected.to validate_presence_of(:desired_end_date) }
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
        expect(inquiry.errors[:breakfast]).to include("は宿泊を選択した場合のみ利用できます")
      end

      it "is valid when both breakfast and accommodation are true" do
        inquiry = build(:inquiry, breakfast: true, accommodation: true)
        expect(inquiry).to be_valid
      end
    end

    context "end date validation" do
      it "is invalid when desired_end_date is before desired_date" do
        inquiry = build(:inquiry, desired_date: Date.new(2026, 4, 5), desired_end_date: Date.new(2026, 4, 3))
        expect(inquiry).not_to be_valid
        expect(inquiry.errors[:desired_end_date]).to include("は利用開始日以降の日付を指定してください")
      end

      it "is valid when desired_end_date equals desired_date" do
        inquiry = build(:inquiry, desired_date: Date.new(2026, 4, 1), desired_end_date: Date.new(2026, 4, 1))
        expect(inquiry).to be_valid
      end

      it "is valid when desired_end_date is after desired_date" do
        inquiry = build(:inquiry, desired_date: Date.new(2026, 4, 1), desired_end_date: Date.new(2026, 4, 3))
        expect(inquiry).to be_valid
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:facility) }
    it { is_expected.to belong_to(:customer).optional }
    it { is_expected.to have_one(:quote).dependent(:destroy) }
    it { is_expected.to have_one(:reservation).dependent(:destroy) }
  end

  describe "#date_range" do
    it "returns the range from desired_date to desired_end_date" do
      inquiry = build(:inquiry, desired_date: Date.new(2026, 4, 1), desired_end_date: Date.new(2026, 4, 3))
      expect(inquiry.date_range).to eq(Date.new(2026, 4, 1)..Date.new(2026, 4, 3))
    end
  end

  describe "#num_nights" do
    it "returns the number of nights" do
      inquiry = build(:inquiry, desired_date: Date.new(2026, 4, 1), desired_end_date: Date.new(2026, 4, 3))
      expect(inquiry.num_nights).to eq(2)
    end

    it "returns 0 for same-day use" do
      inquiry = build(:inquiry, desired_date: Date.new(2026, 4, 1), desired_end_date: Date.new(2026, 4, 1))
      expect(inquiry.num_nights).to eq(0)
    end
  end
end
