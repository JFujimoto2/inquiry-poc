require "rails_helper"

RSpec.describe ReservationMailer, type: :mailer do
  let(:facility) { create(:facility, name: "Test Resort", sender_email: "info@test.com") }
  let(:customer) { create(:customer, company_name: "Acme Corp", contact_name: "Taro Yamada", email: "taro@acme.com") }
  let(:reservation) do
    create(:reservation,
      facility:,
      customer:,
      check_in_date: Date.new(2026, 5, 1),
      check_out_date: Date.new(2026, 5, 3),
      num_people: 5,
      total_amount: 75_000
    )
  end
  let!(:email_template) do
    create(:email_template,
      :reservation_confirmation,
      facility:,
      subject: "Reservation Confirmed - {{facility_name}}",
      body: "Dear {{contact_name}},\n\nYour reservation at {{facility_name}} has been confirmed.\nCheck-in: {{check_in_date}}\nGuests: {{num_people}}"
    )
  end

  describe "#confirmation" do
    let(:mail) { described_class.confirmation(reservation) }

    it "sends to customer email" do
      expect(mail.to).to eq([ "taro@acme.com" ])
    end

    it "sends from facility email" do
      expect(mail.from).to eq([ "info@test.com" ])
    end

    it "interpolates subject" do
      expect(mail.subject).to eq("Reservation Confirmed - Test Resort")
    end

    it "interpolates body text" do
      body = mail.text_part.body.to_s
      expect(body).to include("Dear Taro Yamada")
      expect(body).to include("Test Resort")
      expect(body).to include("2026-05-01")
      expect(body).to include("5")
    end
  end
end
