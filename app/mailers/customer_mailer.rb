class CustomerMailer < ApplicationMailer
  def magic_link(customer, token)
    @customer = customer
    @magic_link_url = verify_mypage_session_url(token:)

    mail(
      to: customer.email,
      subject: "Login Link - Mypage"
    )
  end
end
