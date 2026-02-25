class ReservationStatusManager
  class InvalidTransitionError < StandardError; end

  VALID_TRANSITIONS = {
    "pending_confirmation" => %w[confirmed cancelled],
    "confirmed" => %w[checked_in cancelled],
    "checked_in" => %w[checked_out],
    "checked_out" => [],
    "cancelled" => []
  }.freeze

  def initialize(reservation)
    @reservation = reservation
  end

  def transition_to!(new_status)
    unless can_transition_to?(new_status)
      raise InvalidTransitionError,
        "Cannot transition from #{@reservation.status} to #{new_status}"
    end

    @reservation.update!(status: new_status)
    set_timestamps(new_status)
    enqueue_jobs(new_status)
    @reservation
  end

  def can_transition_to?(new_status)
    allowed_transitions.include?(new_status)
  end

  def allowed_transitions
    VALID_TRANSITIONS.fetch(@reservation.status, [])
  end

  private

  def set_timestamps(new_status)
    case new_status
    when "confirmed"
      @reservation.update!(confirmed_at: Time.current)
    when "cancelled"
      @reservation.update!(cancelled_at: Time.current)
    end
  end

  def enqueue_jobs(new_status)
    if new_status == "confirmed"
      ReservationConfirmationJob.perform_later(@reservation)
    end
  end
end
