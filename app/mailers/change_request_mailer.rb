class ChangeRequestMailer < ApplicationMailer
  def admin_notification(change_request)
    @change_request = change_request
    @reservation = change_request.reservation
    @customer = change_request.customer

    admin_emails = User.where(role: "admin").pluck(:email_address)
    return if admin_emails.empty?

    mail(
      to: admin_emails,
      subject: "変更リクエスト ##{change_request.id} - #{@customer.company_name}"
    )
  end

  def customer_response(change_request)
    @change_request = change_request
    @reservation = change_request.reservation
    @customer = change_request.customer

    status_label = ApplicationController.helpers.change_request_status_label(@change_request.status)
    mail(
      to: @customer.email,
      subject: "変更リクエスト更新 - #{status_label}"
    )
  end
end
