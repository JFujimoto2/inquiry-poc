class ReservationMailer < ApplicationMailer
  def confirmation(reservation)
    @reservation = reservation
    @customer = reservation.customer
    @facility = reservation.facility
    template = @facility.email_templates.find_by!(template_type: "reservation_confirmation")

    subject = interpolate(template.subject)
    @body_text = interpolate(template.body)

    mail(
      to: @customer.email,
      from: @facility.sender_email,
      subject:
    )
  end

  private

  def interpolate(text)
    data = {
      "facility_name" => @facility.name,
      "company_name" => @customer.company_name,
      "contact_name" => @customer.contact_name,
      "check_in_date" => @reservation.check_in_date.to_s,
      "check_out_date" => @reservation.check_out_date.to_s,
      "num_people" => @reservation.num_people.to_s,
      "total_amount" => @reservation.total_amount.to_s
    }
    text.gsub(/\{\{(\w+)\}\}/) { |_| data[$1] || "{{#{$1}}}" }
  end
end
