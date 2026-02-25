require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_uniqueness_of(:email_address).case_insensitive }
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_inclusion_of(:role).in_array(User::ROLES) }
    it { is_expected.to have_secure_password }
  end

  describe "associations" do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
  end

  describe "#admin?" do
    it "returns true for admin role" do
      expect(build(:user, :admin)).to be_admin
    end

    it "returns false for staff role" do
      expect(build(:user, :staff)).not_to be_admin
    end
  end

  describe "#staff?" do
    it "returns true for staff role" do
      expect(build(:user, :staff)).to be_staff
    end

    it "returns false for admin role" do
      expect(build(:user, :admin)).not_to be_staff
    end
  end

  describe "email normalization" do
    it "strips and downcases email" do
      user = create(:user, email_address: "  USER@Example.COM  ")
      expect(user.email_address).to eq("user@example.com")
    end
  end
end
