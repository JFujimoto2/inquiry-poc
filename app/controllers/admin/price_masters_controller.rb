module Admin
  class PriceMastersController < BaseController
    before_action :set_price_master, only: %i[edit update destroy]

    def index
      @facilities = Facility.includes(:price_masters).order(:name)
      @price_masters = PriceMaster.includes(:facility).order(:facility_id, :item_type, :day_type)
    end

    def new
      @price_master = PriceMaster.new
    end

    def create
      @price_master = PriceMaster.new(price_master_params)
      if @price_master.save
        redirect_to admin_price_masters_path, notice: "Price master was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @price_master.update(price_master_params)
        redirect_to admin_price_masters_path, notice: "Price master was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @price_master.destroy!
      redirect_to admin_price_masters_path, notice: "Price master was successfully deleted.", status: :see_other
    end

    private

    def set_price_master
      @price_master = PriceMaster.find(params[:id])
    end

    def price_master_params
      params.require(:price_master).permit(:facility_id, :item_type, :day_type, :unit_price)
    end
  end
end
