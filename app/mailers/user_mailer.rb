class UserMailer < ApplicationMailer

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup.subject


  # require 'sendgrid-ruby'
  # include SendGrid
  #
  def signup(user)
    @user = user
    @greeting = "Thanks for signing up! Your username is: #{@user.username}."

    mail(
      to: @user.email,
      from: 'info@socialdeck.xyz',
      subject: 'Welcome to SocialDeck!'
    )

    # from = SendGrid::Email.new(email: 'info@socialdeck.xyz')
    # to = SendGrid::Email.new(email: '@user.email')
    # subject = 'Welcome to SocialDeck'
    # content = SendGrid::Content.new(type: 'text/plain', value: 'Thank you for signing up for SocialDeck! Your username is: '@user.username)
    # mail = SendGrid::Mail.new(from, subject, to, content)

    # sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    # response = sg.client.mail._('send').post(request_body: mail.to_json)
    # puts response.status_code
    # puts response.body
    # puts response.parsed_body
    # puts response.headers
  end

  def password_reset
    @user = user
    @greeting = "Forgot Password?"

    mail(
      to: @user.email,
      from: 'info@socialdeck.xyz', 
      subject: 'Your Password Reset Request'
    )

    # from = SendGrid::Email.new(email: 'info@socialdeck.xyz')
    # to = SendGrid::Email.new(email: '@user.email')
    # subject = 'Forgot Password?'
    # content = SendGrid::Content.new(type: 'text/plain', value: 'You requested a password reset. Please use the following link to update your pasword: ') 
    # <%= link_to 'Update password', edit_password_url(@resource, reset_password_token: @token) %>
    # mail = SendGrid::Mail.new(from, subject, to, content)

    # sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    # response = sg.client.mail._('send').post(request_body: mail.to_json)
    # puts response.status_code
    # puts response.body
    # puts response.parsed_body
    # puts response.headers
  end

end