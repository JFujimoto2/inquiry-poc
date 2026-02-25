class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user
    mail subject: "パスワードリセット", to: user.email_address
  end
end
