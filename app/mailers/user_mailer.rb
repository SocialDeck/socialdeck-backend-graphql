class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup.subject
  #
  def signup(user)
    @user = user
    @greeting = "Thanks for signing up! Your username is: #{@user.username}."

    mail(
      to: @user.email,
      from: 'info@socialdeck.xyz',
      subject: 'Welcome to SocialDeck!'
    )

  end

  def password_reset
    @user = user
    @greeting = "Forgot Password?"

    mail(
      to: @user.email,
      from: 'info@socialdeck.xyz', 
      subject: 'Your Password Reset Request'
    )

  end

end