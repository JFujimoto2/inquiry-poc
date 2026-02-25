module Mypage
  class ChangeRequestsController < BaseController
    def new
      @reservation = current_customer.reservations.find(params[:reservation_id])
      @change_request = ChangeRequest.new
    end

    def create
      @reservation = current_customer.reservations.find(params[:reservation_id])
      @change_request = @reservation.change_requests.build(change_request_params)
      @change_request.customer = current_customer

      if @change_request.save
        ChangeRequestNotificationJob.perform_later(@change_request)
        redirect_to mypage_reservation_path(@reservation), notice: "Change request submitted successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def change_request_params
      params.require(:change_request).permit(:request_details)
    end
  end
end
