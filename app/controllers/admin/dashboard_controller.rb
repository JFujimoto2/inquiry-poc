module Admin
  class DashboardController < BaseController
    RECENT_INQUIRIES_LIMIT = 10

    def index
      @recent_inquiries = Inquiry.includes(:facility, :quote)
                                  .order(created_at: :desc)
                                  .limit(RECENT_INQUIRIES_LIMIT)
      @stats = {
        total_inquiries: Inquiry.count,
        quotes_sent: Quote.where(status: Quote::STATUS_SENT).count,
        quotes_pending: Quote.where(status: Quote::STATUS_PENDING).count,
        quotes_failed: Quote.where(status: Quote::STATUS_FAILED).count,
        reservations_pending: Reservation.where(status: Reservation::STATUS_PENDING_CONFIRMATION).count,
        reservations_confirmed: Reservation.where(status: Reservation::STATUS_CONFIRMED).count,
        reservations_total: Reservation.count
      }
    end
  end
end
