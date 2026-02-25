require "rails_helper"

RSpec.describe EmailTemplate, type: :model do
  describe "validations" do
    subject { build(:email_template) }

    it { is_expected.to validate_presence_of(:subject) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:template_type) }
    it { is_expected.to validate_inclusion_of(:template_type).in_array(EmailTemplate::TEMPLATE_TYPES) }
    it { is_expected.to validate_uniqueness_of(:template_type).scoped_to(:facility_id) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:facility) }
  end
end
