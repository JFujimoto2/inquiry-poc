module Mypage
  class CustomerSessionsController < ApplicationController
    skip_before_action :require_authentication
    layout "mypage"

    def new; end

    def create
      customer = Customer.find_by(email: params[:email])
      if customer
        CustomerMagicLinkSender.new(customer).call
      end
      redirect_to new_mypage_session_path, notice: "ご登録のメールアドレスにログインリンクをお送りしました。"
    end

    def verify
      token_digest = Digest::SHA256.hexdigest(params[:token])
      customer_session = CustomerSession.valid.find_by(token_digest:)

      if customer_session
        start_customer_session(customer_session)
        redirect_to mypage_root_path, notice: "ログインしました。"
      else
        redirect_to new_mypage_session_path, alert: "リンクが無効または期限切れです。再度リクエストしてください。"
      end
    end

    def destroy
      terminate_customer_session
      redirect_to new_mypage_session_path, notice: "ログアウトしました。", status: :see_other
    end

    private

    include CustomerAuthentication

    def require_customer_authentication
      # Skip for session actions
    end
  end
end
