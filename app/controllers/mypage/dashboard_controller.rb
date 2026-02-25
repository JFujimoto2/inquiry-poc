module Mypage
  class DashboardController < BaseController
    def index
      @reservations = current_customer.reservations
                                       .includes(:facility)
                                       .order(check_in_date: :desc)
    end
  end
end
