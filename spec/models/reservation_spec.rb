require "rails_helper"

RSpec.describe Reservation, type: :model do
  describe "validations" do
    subject { build(:reservation) }

    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_inclusion_of(:status).in_array(Reservation::STATUSES) }
    it { is_expected.to validate_presence_of(:check_in_date) }
    it { is_expected.to validate_presence_of(:num_people) }
    it { is_expected.to validate_numericality_of(:num_people).is_greater_than(0) }

    context "check_out_date validation" do
      it "is invalid when check_out_date is before check_in_date" do
        reservation = build(:reservation, check_in_date: Date.new(2026, 4, 2), check_out_date: Date.new(2026, 4, 1))
        expect(reservation).not_to be_valid
        expect(reservation.errors[:check_out_date]).to include("must be after check-in date")
      end

      it "is invalid when check_out_date equals check_in_date" do
        reservation = build(:reservation, check_in_date: Date.new(2026, 4, 1), check_out_date: Date.new(2026, 4, 1))
        expect(reservation).not_to be_valid
        expect(reservation.errors[:check_out_date]).to include("must be after check-in date")
      end

      it "is valid when check_out_date is after check_in_date" do
        reservation = build(:reservation, check_in_date: Date.new(2026, 4, 1), check_out_date: Date.new(2026, 4, 3))
        expect(reservation).to be_valid
      end

      it "is valid when check_out_date is nil" do
        reservation = build(:reservation, check_out_date: nil)
        expect(reservation).to be_valid
      end
    end
  end

  describe "associations" do
    it { is_expected.to belong_to(:inquiry) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to belong_to(:facility) }
  end

  describe "scopes" do
    let!(:active_reservation) { create(:reservation, :confirmed) }
    let!(:cancelled_reservation) { create(:reservation, :cancelled) }
    let!(:upcoming_reservation) { create(:reservation, :confirmed, check_in_date: Date.current + 7.days) }
    let!(:past_reservation) { create(:reservation, :confirmed, check_in_date: Date.current - 7.days) }

    describe ".active" do
      it "excludes cancelled reservations" do
        expect(Reservation.active).to include(active_reservation)
        expect(Reservation.active).not_to include(cancelled_reservation)
      end
    end

    describe ".upcoming" do
      it "returns only future active reservations" do
        expect(Reservation.upcoming).to include(upcoming_reservation)
        expect(Reservation.upcoming).not_to include(past_reservation)
        expect(Reservation.upcoming).not_to include(cancelled_reservation)
      end
    end
  end
end
