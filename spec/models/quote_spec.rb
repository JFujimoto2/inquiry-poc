require "rails_helper"

RSpec.describe Quote, type: :model do
  describe "validations" do
    subject { build(:quote) }

    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Quote::STATUSES) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:inquiry) }
  end

  describe "status transitions" do
    it "defaults to pending" do
      quote = create(:quote)
      expect(quote.status).to eq(Quote::STATUS_PENDING)
    end

    it "can be generated" do
      quote = create(:quote, :generated)
      expect(quote.status).to eq(Quote::STATUS_GENERATED)
      expect(quote.pdf_data).to be_present
    end

    it "can be sent" do
      quote = create(:quote, :sent)
      expect(quote.status).to eq(Quote::STATUS_SENT)
      expect(quote.sent_at).to be_present
    end

    it "can be failed" do
      quote = create(:quote, :failed)
      expect(quote.status).to eq(Quote::STATUS_FAILED)
    end
  end
end
