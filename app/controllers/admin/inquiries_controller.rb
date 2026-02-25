module Admin
  class InquiriesController < BaseController
    def index
      @inquiries = Inquiry.includes(:facility, :quote, :customer, :reservation).order(created_at: :desc)
    end

    def show
      @inquiry = Inquiry.includes(:facility, :quote, :customer, :reservation).find(params[:id])
    end
  end
end
