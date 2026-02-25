module Admin
  class ReservationsController < BaseController
    before_action :set_reservation, only: %i[show edit update destroy transition]

    def index
      @reservations = Reservation.includes(:facility, :customer, :inquiry).order(created_at: :desc)
      @reservations = @reservations.where(status: params[:status]) if params[:status].present?
    end

    def show
      @status_manager = ReservationStatusManager.new(@reservation)
    end

    def new
      @inquiry = Inquiry.find(params[:inquiry_id]) if params[:inquiry_id]
      @reservation = Reservation.new
    end

    def create
      if params[:inquiry_id].present?
        inquiry = Inquiry.find(params[:inquiry_id])
        @reservation = CreateReservationFromInquiry.new(inquiry).call
        redirect_to admin_reservation_path(@reservation), notice: "Reservation was successfully created from inquiry."
      else
        @reservation = Reservation.new(reservation_params)
        if @reservation.save
          redirect_to admin_reservation_path(@reservation), notice: "Reservation was successfully created."
        else
          render :new, status: :unprocessable_entity
        end
      end
    end

    def edit; end

    def update
      if @reservation.update(reservation_params)
        redirect_to admin_reservation_path(@reservation), notice: "Reservation was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @reservation.destroy!
      redirect_to admin_reservations_path, notice: "Reservation was successfully deleted.", status: :see_other
    end

    def transition
      manager = ReservationStatusManager.new(@reservation)
      manager.transition_to!(params[:status])
      redirect_to admin_reservation_path(@reservation), notice: "Reservation status updated to #{params[:status].titleize}."
    rescue ReservationStatusManager::InvalidTransitionError => e
      redirect_to admin_reservation_path(@reservation), alert: e.message
    end

    private

    def set_reservation
      @reservation = Reservation.find(params[:id])
    end

    def reservation_params
      params.require(:reservation).permit(
        :inquiry_id, :customer_id, :facility_id, :status,
        :check_in_date, :check_out_date, :num_people,
        :total_amount, :admin_notes
      )
    end
  end
end
