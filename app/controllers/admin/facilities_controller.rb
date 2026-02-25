module Admin
  class FacilitiesController < BaseController
    before_action :set_facility, only: %i[show edit update destroy]

    def index
      @facilities = Facility.order(:name)
    end

    def show; end

    def new
      @facility = Facility.new
    end

    def create
      @facility = Facility.new(facility_params)
      if @facility.save
        redirect_to admin_facility_path(@facility), notice: "施設を作成しました。"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @facility.update(facility_params)
        redirect_to admin_facility_path(@facility), notice: "施設を更新しました。"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @facility.destroy!
      redirect_to admin_facilities_path, notice: "施設を削除しました。", status: :see_other
    end

    private

    def set_facility
      @facility = Facility.find(params[:id])
    end

    def facility_params
      params.require(:facility).permit(:name, :sender_email, :sender_domain, :email_signature)
    end
  end
end
