class ReservationConfirmationJob < ApplicationJob
  queue_as :default

  def perform(reservation)
    ReservationMailer.confirmation(reservation).deliver_now
  end
end
