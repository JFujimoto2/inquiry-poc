require "rails_helper"

RSpec.describe ChangeRequest, type: :model do
  describe "validations" do
    subject { build(:change_request) }

    it { is_expected.to validate_presence_of(:request_details) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(ChangeRequest::STATUSES) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:reservation) }
    it { is_expected.to belong_to(:customer) }
  end

  describe "scopes" do
    let!(:pending_request) { create(:change_request, status: ChangeRequest::STATUS_PENDING) }
    let!(:approved_request) { create(:change_request, :approved) }

    describe ".pending" do
      it "returns only pending requests" do
        expect(ChangeRequest.pending).to include(pending_request)
        expect(ChangeRequest.pending).not_to include(approved_request)
      end
    end
  end
end
