class CreateReservationFromInquiry
  def initialize(inquiry)
    @inquiry = inquiry
  end

  def call
    ActiveRecord::Base.transaction do
      customer = find_or_create_customer
      link_customer_to_inquiry(customer)
      create_reservation(customer)
    end
  end

  private

  def find_or_create_customer
    Customer.find_or_create_by!(email: @inquiry.email) do |c|
      c.company_name = @inquiry.company_name
      c.contact_name = @inquiry.contact_name
    end
  end

  def link_customer_to_inquiry(customer)
    @inquiry.update!(customer:) unless @inquiry.customer_id
  end

  def create_reservation(customer)
    Reservation.create!(
      inquiry: @inquiry,
      customer:,
      facility: @inquiry.facility,
      status: Reservation::STATUS_PENDING_CONFIRMATION,
      check_in_date: @inquiry.desired_date,
      num_people: @inquiry.num_people,
      total_amount: @inquiry.total_amount
    )
  end
end
