module Mypage
  class ReservationsController < BaseController
    def show
      @reservation = current_customer.reservations
                                      .includes(:facility, inquiry: :quote)
                                      .find(params[:id])
    end
  end
end
