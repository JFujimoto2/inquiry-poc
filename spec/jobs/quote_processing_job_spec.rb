require "rails_helper"

RSpec.describe QuoteProcessingJob, type: :job do
  let(:facility) { create(:facility) }
  let(:conference_room_price) { 5_000 }
  let(:inquiry) do
    create(:inquiry,
      facility: facility,
      conference_room: true,
      lunch: false, dinner: false, accommodation: false, breakfast: false
    )
  end
  let(:quote) { create(:quote, inquiry: inquiry) }

  before do
    create(:price_master, facility: facility, item_type: "conference_room", day_type: "weekday", unit_price: conference_room_price)
    create(:email_template, facility: facility)
  end

  describe "#perform" do
    it "generates PDF, sends email, and updates status to sent" do
      described_class.perform_now(quote.id)

      quote.reload
      expect(quote.status).to eq(Quote::STATUS_SENT)
      expect(quote.pdf_data).to be_present
      expect(quote.pdf_data).to start_with("%PDF")
      expect(quote.sent_at).to be_present
    end

    it "updates total_amount on the inquiry" do
      described_class.perform_now(quote.id)

      num_days = inquiry.date_range.count
      expected_total = conference_room_price * inquiry.num_people * num_days
      expect(inquiry.reload.total_amount).to eq(expected_total)
    end

    it "sends an email with PDF attachment" do
      expect {
        described_class.perform_now(quote.id)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to include(inquiry.email)
      expect(mail.attachments.size).to eq(1)
      expect(mail.attachments.first.filename).to eq("quote.pdf")
    end

    it "marks quote as failed on error" do
      allow(QuotePdfGenerator).to receive(:new).and_raise(StandardError, "PDF generation failed")

      expect {
        described_class.perform_now(quote.id)
      }.to raise_error(StandardError)

      expect(quote.reload.status).to eq(Quote::STATUS_FAILED)
    end
  end
end
