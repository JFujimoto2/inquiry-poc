module Admin
  class DashboardController < BaseController
    RECENT_INQUIRIES_LIMIT = 10

    def index
      @recent_inquiries = Inquiry.includes(:facility, :quote)
                                  .order(created_at: :desc)
                                  .limit(RECENT_INQUIRIES_LIMIT)
      @stats = {
        total_inquiries: Inquiry.count,
        quotes_sent: Quote.where(status: "sent").count,
        quotes_pending: Quote.where(status: "pending").count,
        quotes_failed: Quote.where(status: "failed").count,
        reservations_pending: Reservation.where(status: "pending_confirmation").count,
        reservations_confirmed: Reservation.where(status: "confirmed").count,
        reservations_total: Reservation.count
      }
    end
  end
end
