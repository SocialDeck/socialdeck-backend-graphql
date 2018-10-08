class UserNotifierMailer < ApplicationMailer
    default :from => 'info@socialdeck.com'
  
    # send a signup email to the user, pass in the user object that contains the user's email address
    def send_signup_email(user)
      @user = user
      mail( 
        :to => @user.email,
        :subject => 'Thanks for signing up for our amazing app' 
      )
    end

    def send_update_email(user)
      @user = user
      mail(
        :to => @user.email,
        :subject => 'Your account has been updated!'
      )
    end

    def send_reset_password_email(user)
      @user = user
      mail(
        :to => @user.email,
        :subject => 'Reset Password Request'
      )
    end

    def send_connection_email(user)
      @user = user
      mail(
        :to => @user.email,
        :subject => 'New Connection!'
      )
    end

    def send_connection_update_email(user)
      @user = user
      mail(
        :to => @user.email,
        :subject => 'Connection Update!'
      )
    end

end
