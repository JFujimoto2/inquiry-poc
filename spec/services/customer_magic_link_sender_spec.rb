require "rails_helper"

RSpec.describe CustomerMagicLinkSender do
  let(:customer) { create(:customer) }

  describe "#call" do
    it "creates a customer session" do
      expect {
        described_class.new(customer).call
      }.to change(CustomerSession, :count).by(1)
    end

    it "creates session with correct expiry" do
      described_class.new(customer).call
      session = CustomerSession.last
      expect(session.expires_at).to be_within(5.seconds).of(CustomerSession::MAGIC_LINK_EXPIRY.from_now)
    end

    it "enqueues a magic link email" do
      expect {
        described_class.new(customer).call
      }.to have_enqueued_job(ActionMailer::MailDeliveryJob)
    end

    it "returns the raw token" do
      token = described_class.new(customer).call
      expect(token).to be_present
      expect(token.length).to be > 20
    end
  end
end
