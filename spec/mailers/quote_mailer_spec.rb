require "rails_helper"

RSpec.describe QuoteMailer, type: :mailer do
  let(:facility) { create(:facility, name: "Test Resort", sender_email: "info@test.com") }
  let(:inquiry) do
    create(:inquiry,
      facility: facility,
      company_name: "Acme Corp",
      contact_name: "Test User",
      email: "user@acme.com",
      total_amount: 50_000
    )
  end
  let(:email_template) do
    create(:email_template,
      facility: facility,
      subject: "Quote for {{company_name}}",
      body: "Dear {{contact_name}},\n\nYour quote from {{facility_name}} is attached."
    )
  end
  let(:quote) { create(:quote, :generated, inquiry: inquiry) }

  before { email_template }

  describe "#send_quote" do
    let(:mail) { described_class.send_quote(quote) }

    it "sends to inquiry email" do
      expect(mail.to).to eq([ "user@acme.com" ])
    end

    it "sends from facility email" do
      expect(mail.from).to eq([ "info@test.com" ])
    end

    it "interpolates subject" do
      expect(mail.subject).to eq("Quote for Acme Corp")
    end

    it "attaches PDF" do
      expect(mail.attachments.size).to eq(1)
      expect(mail.attachments.first.filename).to eq("quote.pdf")
    end

    it "interpolates body text" do
      body = mail.text_part.body.to_s
      expect(body).to include("Dear Test User")
      expect(body).to include("Test Resort")
    end
  end
end
