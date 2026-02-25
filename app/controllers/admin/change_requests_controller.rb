module Admin
  class ChangeRequestsController < BaseController
    before_action :set_change_request, only: %i[show respond]

    def index
      @change_requests = ChangeRequest.includes(:customer, reservation: :facility).order(created_at: :desc)
      @change_requests = @change_requests.where(status: params[:status]) if params[:status].present?
    end

    def show; end

    def respond
      @change_request.update!(
        status: respond_params[:status],
        admin_response: respond_params[:admin_response]
      )
      ChangeRequestMailer.customer_response(@change_request).deliver_later
      redirect_to admin_change_request_path(@change_request),
                  notice: "Change request #{@change_request.status}."
    end

    private

    def set_change_request
      @change_request = ChangeRequest.find(params[:id])
    end

    def respond_params
      params.require(:change_request).permit(:status, :admin_response)
    end
  end
end
