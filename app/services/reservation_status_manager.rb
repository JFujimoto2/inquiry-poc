class ReservationStatusManager
  class InvalidTransitionError < StandardError; end

  VALID_TRANSITIONS = {
    Reservation::STATUS_PENDING_CONFIRMATION =>
      [ Reservation::STATUS_CONFIRMED, Reservation::STATUS_CANCELLED ],
    Reservation::STATUS_CONFIRMED =>
      [ Reservation::STATUS_CHECKED_IN, Reservation::STATUS_CANCELLED ],
    Reservation::STATUS_CHECKED_IN =>
      [ Reservation::STATUS_CHECKED_OUT ],
    Reservation::STATUS_CHECKED_OUT => [],
    Reservation::STATUS_CANCELLED => []
  }.freeze

  def initialize(reservation)
    @reservation = reservation
  end

  def transition_to!(new_status)
    unless can_transition_to?(new_status)
      raise InvalidTransitionError,
        "「#{@reservation.status}」から「#{new_status}」への変更はできません"
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
    when Reservation::STATUS_CONFIRMED
      @reservation.update!(confirmed_at: Time.current)
    when Reservation::STATUS_CANCELLED
      @reservation.update!(cancelled_at: Time.current)
    end
  end

  def enqueue_jobs(new_status)
    if new_status == Reservation::STATUS_CONFIRMED
      ReservationConfirmationJob.perform_later(@reservation)
    end
  end
end
