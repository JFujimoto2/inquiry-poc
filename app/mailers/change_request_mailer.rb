class ChangeRequestMailer < ApplicationMailer
  def admin_notification(change_request)
    @change_request = change_request
    @reservation = change_request.reservation
    @customer = change_request.customer

    admin_emails = User.where(role: "admin").pluck(:email_address)
    return if admin_emails.empty?

    mail(
      to: admin_emails,
      subject: "Change Request ##{change_request.id} - #{@customer.company_name}"
    )
  end

  def customer_response(change_request)
    @change_request = change_request
    @reservation = change_request.reservation
    @customer = change_request.customer

    mail(
      to: @customer.email,
      subject: "Change Request Update - #{@change_request.status.titleize}"
    )
  end
end
