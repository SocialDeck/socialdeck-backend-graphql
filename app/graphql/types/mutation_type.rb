module Types
  class MutationType < Types::BaseObject

    field :login, Types::TokenType, null: true do
      argument :user, Types::AuthProviderUsernameInput, required: true
    end

    def login(user:)
      credential_user = User.find_by_username(user[:username])
      raise GraphQL::ExecutionError, "User does not exist" unless credential_user

      if credential_user.authenticate(user[:password])
        exp = user[:remember] ? 1.month.from_now : 2.hours.from_now
        OpenStruct.new({
          token: JsonWebToken.encode(user_id: credential_user.id, exp: exp),
          user: credential_user
        })
      else
        raise GraphQL::ExecutionError, "Invalid Password"        
      end
    end    

    # User Mutations

    field :createUser, Types::TokenType, null: false do
      argument :user, Types::AuthProviderUsernameInput, required: true
      argument :name, String, required: true
      argument :email, String, required: true
    end

    def create_user(user:, name:, email:)
      user = User.new(
          email: email,
          name: name,
          username: user[:username],
          password: user[:password]
        )

      if user.save
        token = JsonWebToken.encode(user_id: user.id, exp: 48.hours.from_now)
        UserNotifierMailer.send_signup_email(user, token).deliver
        OpenStruct.new({
          token: JsonWebToken.encode(user_id: user.id),
          user: user
        }) 
      end       
    end

    field :confirmUser, Types::UserType, null: false do
      argument :token, String, required: true
    end

    def confirm_user(token:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      if user.update(confirmed: true)
        user
      end
    end

    field :updateUser, Types::UserType, null: true do
      argument :token, String, required: true
      argument :username, String, required: false
      argument :name, String, required: false
      argument :password, String, required: false
      argument :email, String, required: false
    end

    def update_user(token:, username:nil, password:nil, name:nil, email:nil)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      user_params = {email: email.present? ? email : nil,
                      name: name.present? ? name : nil,
                      username: username.present? ? username : nil,
                      password: password.present? ? password : nil}.compact

      if user.update(user_params)
        # UserNotifierMailer.send_update_email(user).deliver
        user
      end
    end

    field :reset_password, Types::NullType, null: false do
      argument :email, String, required: true
   end

    def reset_password(email:)
      user = User.find_by_email(email)
      token = JsonWebToken.encode(user_id: user.id, exp: 3.hours.from_now)
      UserNotifierMailer.send_reset_password_email(user, token).deliver

      OpenStruct.new({
        message: "Message sent"
      })

    end
    

    field :blockUser, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :user_id, ID, required: true
    end

    def block_user(token:, user_id:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      connections = Connection.where(user_id:user_id, contact_id:user.id)
      connections.destroy_all

      Connection.create!(
            user_id: user_id,
            contact_id: user.id,
            card_id: -1
          )

    end

    field :destroyUser, Types::NullType, null: true do
      argument :token, String, required: true
    end

    def destroy_user(token:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      if user.destroy
        OpenStruct.new({
          message: "This user has been deleted"
        })
      else
        OpenStruct.new({
          message: user.errors.full_message
        })
      end
    end

    # Card Mutations

    field :createCard, Types::CardType, null: true do
      argument :token, String, required: true
      argument :owned, Boolean, required: true
      argument :card_name, String, required: true
      argument :display_name, String, required: false
      argument :name, String, required: true
      argument :business_name, String, required: false
      argument :address, Types::AddressUpdateInput, required: false
      argument :number, String, required: false
      argument :email, String, required: false
      argument :birth_date, Types::DateTimeType, required: false
      argument :twitter, String, required: false
      argument :linked_in, String, required: false
      argument :facebook, String, required: false
      argument :instagram, String, required: false
      # argument :invite, Boolean, required: false
    end

    def create_card(token:, owned:true, card_name:, display_name:nil, name:, 
                    business_name:nil, number:nil, email:nil, address:nil, birth_date:nil,
                    twitter:nil, facebook:nil, linked_in:nil, instagram:nil)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      if address
        address_object = Address.create!(
          address1: address.address1,
          address2: address.address2,
          city: address.city,
          state: address.state,
          postal_code: address.postal_code
        )
        address_id = address_object.id
      else
        address_id = nil  
      end

      card = Card.create!(
          card_name: card_name,
          display_name: display_name.present? ? display_name : card_name,
          name: name,
          business_name: business_name,
          number: number,
          email: email,
          address_id: address_id,
          author_id: user.id,
          user_id: owned ? user.id : nil,
          birth_date: birth_date,
          twitter: twitter,
          linked_in: linked_in,
          facebook: facebook,
          instagram: instagram
        )

      if not owned
          Connection.create!(
            user_id: user.id,
            contact_id: nil,
            card_id: card.id
          )
      end

      card
    end

    field :updateCard, Types::CardType, null: true do
      argument :id, ID, required:true
      argument :token, String, required: true
      argument :card_name, String, required: false
      argument :display_name, String, required: false
      argument :name, String, required: false
      argument :business_name, String, required: false
      argument :address, Types::AddressUpdateInput, required: false
      argument :number, String, required: false
      argument :email, String, required: false
      argument :birth_date, Types::DateTimeType, required: false
      argument :twitter, String, required: false
      argument :linked_in, String, required: false
      argument :facebook, String, required: false
      argument :instagram, String, required: false
    end

    def update_card(token:, id:, card_name:nil, display_name:nil, name:nil, 
                    business_name:nil, number:nil, email:nil, address:nil, birth_date:nil,
                    twitter:nil, facebook:nil, linked_in:nil, instagram:nil)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end
      
      card = Card.find_by(id: id, author_id:user.id)
      raise GraphQL::ExecutionError, "Card does not exist" unless card


      if address.present?
        if card.address.present?
          address_params = {address1: address.address1.present? ? address.address1 : card.address.address1,
                            address2: address.address2.present? ? address.address2 : card.address.address2, 
                            city: address.city.present? ? address.city : card.address.city, 
                            state: address.state.present? ? address.state : card.address.state, 
                            postal_code: address.postal_code.present? ? address.postal_code : card.address.postal_code}
                            
          address_object = Address.find_by(address_params)
          if address_object.id == card.address.id
            card.update(address_id: nil)
            address_id = nil
          else
            card.address.update(address_params)
            address_id = card.address.id
          end                                  
        else
          address_params = {address1: address.address1.present? ? address.address1 : nil,
                            address2: address.address2.present? ? address.address2 : nil, 
                            city: address.city.present? ? address.city : nil, 
                            state: address.state.present? ? address.state : nil, 
                            postal_code: address.postal_code.present? ? address.postal_code : nil}.compact 


          address_object = Address.create!(address_params)
          address_id = address_object.id
        end
      else
        address_id = nil
      end

      card_params = {card_name: card_name.present? ? card_name : nil, 
                     display_name: display_name.present? ? display_name : nil, 
                     name: name.present? ? name : nil, 
                     business_name: business_name.present? ? business_name : nil, 
                     number: number.present? ? number : nil, 
                     email: email.present? ? email : nil, 
                     address_id: address_id.present? ? address_id : nil,
                     birth_date: birth_date.present? ? birth_date : nil,
                     twitter: twitter.present? ? twitter : nil, 
                     facebook: facebook.present? ? facebook : nil, 
                     linked_in: linked_in.present? ? linked_in : nil, 
                     instagram: instagram.present? ? instagram : nil}.compact

      if card.update(card_params)
        card
      end
      
    end

    field :destroyCard, Types::NullType, null: true do
      argument :token, String, required: true
      argument :id, ID, required: true    
    end

    def destroy_card(token:, id:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      card = Card.find_by(id: id, author_id:user.id)
      raise GraphQL::ExecutionError, "Card does not exist" unless card

      if card.destroy
        OpenStruct.new({
          message: "This card has been deleted"
        })
      else
        OpenStruct.new({
          message: card.errors.full_message
        })
      end
    end

    # Connection Mutations

    field :createConnection, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :card_token, ID, required: true
    end

    def create_connection(token:, card_token:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      begin
        card = AuthorizedCardRequest.call(card_token).result
        raise GraphQL::ExecutionError, "Card does not exist" unless card
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end
       
      connection = Connection.find_by(card_id:card.id, user_id:user.id)
      raise GraphQL::ExecutionError, "This connection already exist" if connection
      
      if card
          connection = Connection.create!(
            user_id: user.id,
            contact_id: card.user_id,
            card_id: card.id
          )
          # UserNotifierMailer.send_connection_email(user).deliver
      end
      connection
    end

    field :updateConnection, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :id, ID, required: true
      argument :card_id, ID, required: true
    end

    def update_connection(token:, id:, card_id:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      connection = Connection.find_by(id:id, contact_id:user.id)
      raise GraphQL::ExecutionError, "Connection does not exist" unless connection

      card = Card.find_by(id:card_id, user_id:user.id)
      raise GraphQL::ExecutionError, "Card does not exist" unless card

      if connection.update(card_id: card.id)
          connection
      end
    end

    field :favorite, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :card_id, ID, required: true
    end

    def favorite(token:, card_id:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      connection = Connection.find_by(card_id:card_id, user_id:user.id)
      raise GraphQL::ExecutionError, "Connection does not exist" unless connection

      if connection.update(favorite: true)
          connection
      end
    end


    field :unfavorite, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :card_id, ID, required: true
    end

    def unfavorite(token:, card_id:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      connection = Connection.find_by(card_id:card_id, user_id:user.id)
      raise GraphQL::ExecutionError, "Connection does not exist" unless connection

      if connection.update(favorite: false)
          connection
      end
    end

    field :destroyConnection, Types::NullType, null: true do
      argument :token, String, required: true
      argument :id, ID, required: true    
    end

    def destroy_connection(token:, id:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      connection = Connection.find_by(id:id, contact_id:user.id) || Connection.find_by(id:id, user_id:user.id)
      raise GraphQL::ExecutionError, "Connection does not exist" unless connection

      if connection.destroy
        OpenStruct.new({
          message: "This connection has been deleted"
        })
      else
        OpenStruct.new({
          message: connection.errors.full_message
        })
      end
    end

    # Log Mutations

    field :createLog, Types::LogType, null: true do
      argument :token, String, required: true
      argument :card_id, ID, required: true
      argument :date, Types::DateTimeType, required: false
      argument :text, String, required: true
    end

    def create_log(token:, card_id:, date:Time.now.to_date, text:)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      connection = Connection.find_by(user_id:user.id, card_id: card_id)
      raise GraphQL::ExecutionError, "Connection does not exist" unless connection

      card = Card.find_by(id:card_id)
      raise GraphQL::ExecutionError, "Card does not exist" unless card

      print connection

      Log.create!(
        user_id: user.id,
        contact_id: card.user_id,
        card_id: card_id,
        date: date, 
        text: text
      )
    end

    field :updateLog, Types::LogType, null: true do
      argument :token, String, required: true
      argument :id, ID, required: true
      argument :date, Types::DateTimeType, required: false
      argument :text, String, required: false
    end

    def update_log(token:, id:, date:nil, text:nil)
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end

      log = Log.find_by(id:id, user_id:user.id)
      raise GraphQL::ExecutionError, "Log does not exist" unless log

      log_params = {date: date.present? ? date : nil,
                    text: text.present? ? text : nil}.compact

      if log.update(log_params)
          log
      end
    end

    field :destroyLog, Types::NullType, null: false do
      argument :token, String, required: true
      argument :id, ID, required: true
    end    

    def destroy_log
      begin
        user = AuthorizeUserRequest.call(token).result
        raise GraphQL::ExecutionError, "User does not exist" unless user
      rescue ExceptionHandler::ExpiredSignature => e
        raise GraphQL::ExecutionError, e.message
      rescue ExceptionHandler::DecodeError => e
        raise GraphQL::ExecutionError, e.message        
      end
      
      log = Log.find_by(id:id, user_id:user.id)
      raise GraphQL::ExecutionError, "Log does not exist" unless log

      if log.destroy
        OpenStruct.new({
          message: "This log has been deleted"
        })
      else
        OpenStruct.new({
          message: log.errors.full_message
        })
      end
    end
  end
end