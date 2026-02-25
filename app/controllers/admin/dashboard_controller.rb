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
        quotes_failed: Quote.where(status: "failed").count
      }
    end
  end
end
