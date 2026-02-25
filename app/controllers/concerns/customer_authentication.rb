module CustomerAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_customer_authentication
    helper_method :current_customer
  end

  private

  def current_customer
    @current_customer ||= find_customer_from_session
  end

  def find_customer_from_session
    return unless cookies.signed[:customer_session_id]

    session_record = CustomerSession.valid.find_by(id: cookies.signed[:customer_session_id])
    session_record&.customer
  end

  def require_customer_authentication
    unless current_customer
      redirect_to new_mypage_session_path, alert: "Please log in to continue."
    end
  end

  def start_customer_session(customer_session)
    cookies.signed.permanent[:customer_session_id] = {
      value: customer_session.id,
      httponly: true,
      same_site: :lax,
      expires: CustomerSession::SESSION_EXPIRY.from_now
    }
  end

  def terminate_customer_session
    if cookies.signed[:customer_session_id]
      CustomerSession.find_by(id: cookies.signed[:customer_session_id])&.destroy
    end
    cookies.delete(:customer_session_id)
  end
end
