module Types
  class MutationType < Types::BaseObject

    field :login, Types::TokenType, null: true do
      argument :user, Types::AuthProviderUsernameInput, required: true
    end

    def login(user:)
      credential_user = User.find_by_username(user[:username])
      if credential_user && credential_user.authenticate(user[:password])
        exp = user[:remember] ? 1.month.from_now : 2.hours.from_now
        OpenStruct.new({
          token: JsonWebToken.encode(user_id: credential_user.id, exp: exp),
          user: credential_user
        })
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
        # UserNotifierMailer.send_signup_email(user, token).deliver
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
      user = AuthorizeUserRequest.call(token).result
      if user.update(confirmed: true)
        user
      end
    end


    field :updateUser, Types::UserType, null: false do
      argument :token, String, required: true
      argument :username, String, required: false
      argument :name, String, required: false
      argument :password, String, required: false
      argument :email, String, required: false
   end

    def update_user(token:, username:nil, password:nil, name:nil, email:nil)
      user = AuthorizeUserRequest.call(token).result
      user_params = {email: email,
                     name: name,
                     username: username,
                     password: password}.compact

      if user.update(user_params)
        # UserNotifierMailer.send_update_email(user).deliver
        user
      end
    end

    field :reset_password, Types::NullType, null: false do
      argument :username, String, required: true
   end

    def reset_password(username:)
      user = User.find_by_username(username)
      token = JsonWebToken.encode(user_id: user.id, exp: 3.hours.from_now)
      # UserNotifierMailer.send_reset_password_email(user, token).deliver

      OpenStruct.new({
        message: "Message sent"
      })

    end
    

    field :blockUser, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :user_id, ID, required: true
    end

    def block_user(token:, user_id:)
      current_user = AuthorizeUserRequest.call(token).result

      connections = Connection.where(user_id:current_user.id, contact_id:user_id)
      connections.destroy_all

      Connection.create!(
            user_id: user_id,
            contact_id: current_user.id,
            card_id: -1
          )

    end

    field :destroyUser, Types::NullType, null: true do
      argument :token, String, required: true
    end

    def destroy_user(token:)
      current_user = AuthorizeUserRequest.call(token).result
      return unless current_user

      if current_user.destroy
        OpenStruct.new({
          message: "This user has been deleted"
        })
      else
        OpenStruct.new({
          message: current_user.errors.full_message
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
      argument :address, Types::AddressInput, required: false
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
      current_user = AuthorizeUserRequest.call(token).result
      if address
        address_object = Address.find_by(address.to_h)
        unless address_object
          address_object = Address.create!(
            address1: address.address1,
            address2: address.address2,
            city: address.city,
            state: address.state,
            postal_code: address.postal_code
          )
        end
        address_id = address_object.id
      else
        address_id = nil  
      end

      card = Card.create!(
          card_name: card_name,
          display_name: display_name || card_name,
          name: name,
          business_name: business_name,
          number: number,
          email: email,
          address_id: address_id,
          author_id: current_user.id,
          user_id: owned ? current_user.id : nil,
          birth_date: birth_date,
          twitter: twitter,
          linked_in: linked_in,
          facebook: facebook,
          instagram: instagram
        )

      if not owned
          Connection.create!(
            user_id: current_user.id,
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
      current_user = AuthorizeUserRequest.call(token).result
      card = Card.find_by(id: id, author_id:current_user.id)
      return unless card

      if address
        card_address = card.address

        address_params = {address1: address.address1 || card_address.address1,
                          address2: address.address2 || card_address.address2, 
                          city: address.city || card_address.city, 
                          state: address.state || card_address.state, 
                          postal_code: address.postal_code || card_address.postal_code}

        address_object = Address.find_by(address_params)
        unless address_object
          address_object = Address.create!(address_params)
        end
        address_id = address_object.id
      else
        address_id = nil  
      end

      card_params = {card_name: card_name, 
                     display_name: display_name, 
                     name: name, 
                     business_name: business_name, 
                     number:number, 
                     email: email, 
                     address_id: address_id,
                     birth_date: birth_date,
                     twitter: twitter, 
                     facebook: facebook, 
                     linked_in: linked_in, 
                     instagram: instagram}.compact

      if card.update(card_params)
        card
      end
      
    end

    field :destroyCard, Types::NullType, null: true do
      argument :token, String, required: true
      argument :id, ID, required: true    
    end

    def destroy_card(token:, id:)
      current_user = AuthorizeUserRequest.call(token).result
      return unless current_user

      card = Card.find_by(id: id, author_id:current_user.id)
      return unless card

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
      user = AuthorizeUserRequest.call(token).result
      card = AuthorizedCardRequest.call(card_token).result

      connection = Connection.find_by(card_id:card.id, user_id:user.id)
      return if connection
      
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
      user = AuthorizeUserRequest.call(token).result
      return unless user

      connection = Connection.find_by(id:id, contact_id:user.id)
      return unless connection

      card = Card.find_by(id:card_id, user_id:user.id)
      return unless card

      if connection.update(card_id: card.id)
          connection
      end
    end

    field :favorite, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :card_id, ID, required: true
    end

    def favorite(token:, card_id:)
      user = AuthorizeUserRequest.call(token).result
      return unless user

      connection = Connection.find_by(card_id:card_id, user_id:user.id)
      return unless connection

      if connection.update(favorite: true)
          connection
      end
    end


    field :unfavorite, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :card_id, ID, required: true
    end

    def unfavorite(token:, card_id:)
      user = AuthorizeUserRequest.call(token).result
      return unless user

      connection = Connection.find_by(card_id:card_id, user_id:user.id)
      return unless connection

      if connection.update(favorite: false)
          connection
      end
    end

    field :destroyConnection, Types::NullType, null: true do
      argument :token, String, required: true
      argument :id, ID, required: true    
    end

    def destroy_connection(token:, id:)
      user = AuthorizeUserRequest.call(token).result
      return unless user

      connection = Connection.find_by(id:id, contact_id:user.id) || Connection.find_by(id:id, user_id:user.id)
      return unless connection

      if connection.destroy
        OpenStruct.new({
          message: "This connection has been deleted"
        })
      else
        OpenStruct.new({
          message: connection.errors.full_message
        })
      end
      # UserNotifierMailer.send_connection_update_email(user).deliver
    end

    # Log Mutations

    field :createLog, Types::LogType, null: true do
      argument :token, String, required: true
      argument :card_id, ID, required: true
      argument :date, Types::DateTimeType, required: false
      argument :text, String, required: true
    end

    def create_log(token:, card_id:, date:Time.now.to_date, text:)
      user = AuthorizeUserRequest.call(token).result
      return unless user
      print User

      connection = Connection.find_by(user_id:user.id, card_id: card_id)
      return unless connection

      card = Card.find_by(id:card_id)
      return unless card

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
      user = AuthorizeUserRequest.call(token).result
      return unless user

      log = Log.find_by(id:id, user_id:user.id)
      return unless log

      log_params = {date: date,
                    text: text}.compact

      if log.update(log_params)
          log
      end
    end

    field :destroyLog, Types::NullType, null: false do
      argument :token, String, required: true
      argument :id, ID, required: true
    end    

    def destroy_log
      user = AuthorizeUserRequest.call(token).result
      return unless user

      log = Log.find_by(id:id, user_id:user.id)
      return unless log

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