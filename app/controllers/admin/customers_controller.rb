module Admin
  class CustomersController < BaseController
    before_action :set_customer, only: %i[show edit update destroy]

    def index
      @customers = Customer.order(:company_name)
      @customers = @customers.where("company_name ILIKE :q OR contact_name ILIKE :q OR email ILIKE :q", q: "%#{params[:q]}%") if params[:q].present?
    end

    def show
      @inquiries = @customer.inquiries.includes(:facility, :quote).order(created_at: :desc)
    end

    def new
      @customer = Customer.new
    end

    def create
      @customer = Customer.new(customer_params)
      if @customer.save
        redirect_to admin_customer_path(@customer), notice: "顧客を作成しました。"
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @customer.update(customer_params)
        redirect_to admin_customer_path(@customer), notice: "顧客を更新しました。"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @customer.destroy!
      redirect_to admin_customers_path, notice: "顧客を削除しました。", status: :see_other
    end

    private

    def set_customer
      @customer = Customer.find(params[:id])
    end

    def customer_params
      params.require(:customer).permit(:company_name, :contact_name, :email, :phone, :notes)
    end
  end
end
