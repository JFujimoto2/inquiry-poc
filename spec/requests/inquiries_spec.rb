require "rails_helper"

RSpec.describe "Inquiries", type: :request do
  let(:facility) { create(:facility) }
  let(:conference_room_price) { 5_000 }
  let(:lunch_price) { 1_500 }

  before do
    create(:price_master, facility: facility, item_type: "conference_room", day_type: "weekday", unit_price: conference_room_price)
    create(:price_master, facility: facility, item_type: "lunch", day_type: "weekday", unit_price: lunch_price)
    create(:email_template, facility: facility)
  end

  describe "GET /inquiries/new" do
    it "renders the inquiry form" do
      get new_inquiry_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("お問い合わせフォーム")
    end
  end

  describe "POST /inquiries" do
    let(:valid_params) do
      {
        inquiry: {
          facility_id: facility.id,
          desired_date: "2026-04-01",
          num_people: 10,
          conference_room: true,
          lunch: true,
          accommodation: false,
          breakfast: false,
          dinner: false,
          company_name: "Test Corp",
          contact_name: "Taro Yamada",
          email: "taro@example.com"
        }
      }
    end

    it "creates an inquiry and redirects to thank you" do
      expect {
        post inquiries_path, params: valid_params
      }.to change(Inquiry, :count).by(1)
        .and change(Quote, :count).by(1)
      expect(response).to redirect_to(thank_you_inquiries_path)
    end

    it "calculates and stores the total amount" do
      post inquiries_path, params: valid_params
      inquiry = Inquiry.last
      num_people = 10
      expected_total = (conference_room_price + lunch_price) * num_people
      expect(inquiry.total_amount).to eq(expected_total)
    end

    it "enqueues a QuoteProcessingJob" do
      expect {
        post inquiries_path, params: valid_params
      }.to have_enqueued_job(QuoteProcessingJob)
    end

    it "re-renders form on validation error" do
      post inquiries_path, params: { inquiry: { facility_id: facility.id, company_name: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /inquiries/thank_you" do
    it "renders the thank you page" do
      get thank_you_inquiries_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("お問い合わせありがとうございます")
    end
  end
end
