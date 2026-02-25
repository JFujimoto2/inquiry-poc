require "rails_helper"

RSpec.describe Facility, type: :model do
  describe "validations" do
    subject { build(:facility) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_presence_of(:sender_email) }
    it { is_expected.to validate_presence_of(:sender_domain) }
  end

  describe "associations" do
    it { is_expected.to have_many(:price_masters).dependent(:destroy) }
    it { is_expected.to have_one(:email_template).dependent(:destroy) }
    it { is_expected.to have_many(:inquiries).dependent(:destroy) }
  end
end
