require "rails_helper"

RSpec.describe ReservationStatusManager do
  let(:reservation) { create(:reservation, status: Reservation::STATUS_PENDING_CONFIRMATION) }
  let(:manager) { described_class.new(reservation) }

  describe "#transition_to!" do
    context "valid transitions" do
      it "transitions from pending_confirmation to confirmed" do
        manager.transition_to!(Reservation::STATUS_CONFIRMED)
        expect(reservation.reload.status).to eq(Reservation::STATUS_CONFIRMED)
      end

      it "transitions from pending_confirmation to cancelled" do
        manager.transition_to!(Reservation::STATUS_CANCELLED)
        expect(reservation.reload.status).to eq(Reservation::STATUS_CANCELLED)
      end

      it "transitions from confirmed to checked_in" do
        reservation.update!(status: Reservation::STATUS_CONFIRMED)
        described_class.new(reservation).transition_to!(Reservation::STATUS_CHECKED_IN)
        expect(reservation.reload.status).to eq(Reservation::STATUS_CHECKED_IN)
      end

      it "transitions from confirmed to cancelled" do
        reservation.update!(status: Reservation::STATUS_CONFIRMED)
        described_class.new(reservation).transition_to!(Reservation::STATUS_CANCELLED)
        expect(reservation.reload.status).to eq(Reservation::STATUS_CANCELLED)
      end

      it "transitions from checked_in to checked_out" do
        reservation.update!(status: Reservation::STATUS_CHECKED_IN)
        described_class.new(reservation).transition_to!(Reservation::STATUS_CHECKED_OUT)
        expect(reservation.reload.status).to eq(Reservation::STATUS_CHECKED_OUT)
      end
    end

    context "invalid transitions" do
      it "raises InvalidTransitionError for checked_out to confirmed" do
        reservation.update!(status: Reservation::STATUS_CHECKED_OUT)
        manager = described_class.new(reservation)
        expect { manager.transition_to!(Reservation::STATUS_CONFIRMED) }
          .to raise_error(ReservationStatusManager::InvalidTransitionError)
      end

      it "raises InvalidTransitionError for cancelled to confirmed" do
        reservation.update!(status: Reservation::STATUS_CANCELLED)
        manager = described_class.new(reservation)
        expect { manager.transition_to!(Reservation::STATUS_CONFIRMED) }
          .to raise_error(ReservationStatusManager::InvalidTransitionError)
      end

      it "raises InvalidTransitionError for pending_confirmation to checked_in" do
        expect { manager.transition_to!(Reservation::STATUS_CHECKED_IN) }
          .to raise_error(ReservationStatusManager::InvalidTransitionError)
      end
    end

    context "timestamps" do
      it "sets confirmed_at when transitioning to confirmed" do
        manager.transition_to!(Reservation::STATUS_CONFIRMED)
        expect(reservation.reload.confirmed_at).to be_within(1.second).of(Time.current)
      end

      it "sets cancelled_at when transitioning to cancelled" do
        manager.transition_to!(Reservation::STATUS_CANCELLED)
        expect(reservation.reload.cancelled_at).to be_within(1.second).of(Time.current)
      end
    end

    context "job enqueue" do
      it "enqueues ReservationConfirmationJob when transitioning to confirmed" do
        expect {
          manager.transition_to!(Reservation::STATUS_CONFIRMED)
        }.to have_enqueued_job(ReservationConfirmationJob).with(reservation)
      end

      it "does not enqueue job for other transitions" do
        expect {
          manager.transition_to!(Reservation::STATUS_CANCELLED)
        }.not_to have_enqueued_job(ReservationConfirmationJob)
      end
    end
  end

  describe "#can_transition_to?" do
    it "returns true for valid transitions" do
      expect(manager.can_transition_to?(Reservation::STATUS_CONFIRMED)).to be true
    end

    it "returns false for invalid transitions" do
      expect(manager.can_transition_to?(Reservation::STATUS_CHECKED_OUT)).to be false
    end
  end

  describe "#allowed_transitions" do
    it "returns allowed statuses for pending_confirmation" do
      expect(manager.allowed_transitions).to eq(
        [ Reservation::STATUS_CONFIRMED, Reservation::STATUS_CANCELLED ]
      )
    end

    it "returns empty array for checked_out" do
      reservation.update!(status: Reservation::STATUS_CHECKED_OUT)
      manager = described_class.new(reservation)
      expect(manager.allowed_transitions).to eq([])
    end
  end
end
