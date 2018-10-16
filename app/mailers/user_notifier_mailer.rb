class UserNotifierMailer < ApplicationMailer
    default :from => 'info@socialdeck.xyz'
  
    # send a signup email to the user, pass in the user object that contains the user's email address
    def send_signup_email(user, token)
      @user = user
      @token = token
      mail( 
        :to => @user.email,
        :subject => 'Thanks for signing up for SocialDeck!' 
      )
    end

    def send_update_email(user)
      @user = user
      mail(
        :to => @user.email,
        :subject => 'Your account has been updated!'
      )
    end

    def send_reset_password_email(user, token)
      @user = user
      @token = token
      mail(
        :to => @user.email,
        :subject => 'Reset Password Request'
      )
    end

    def send_connection_email(user, card_token, requester_name)
      @user = user
      @card_token = card_token
      @requester_name = requester_name
      mail(
        :to => @user.email,
        :subject => "#{@requester_name} is requesting your contatct information."
      )
    end

    def send_card_email(user, card, card_token, email)
      @user = user
      @card_token = card_token
      @card = card
      mail(
        :to => email,
        :subject => "#{card.name} shared their #{card.display_name} card with you!"
      )
    end

end
