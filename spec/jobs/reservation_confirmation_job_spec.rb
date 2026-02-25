require "rails_helper"

RSpec.describe ReservationConfirmationJob, type: :job do
  let(:facility) { create(:facility) }
  let(:reservation) { create(:reservation, facility:) }
  let!(:email_template) { create(:email_template, :reservation_confirmation, facility:) }

  describe "#perform" do
    it "sends a confirmation email" do
      expect {
        described_class.perform_now(reservation)
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "sends to the customer email" do
      described_class.perform_now(reservation)
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([ reservation.customer.email ])
    end
  end
end
