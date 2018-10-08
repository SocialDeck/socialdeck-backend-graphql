module Types
  class MutationType < Types::BaseObject

    field :login, Types::TokenType, null: true do
      argument :user, Types::AuthProviderUsernameInput, required: true
    end

    def login(user:)
      credential_user = User.find_by_username(user[:username])
      if credential_user && credential_user.authenticate(user[:password])
        OpenStruct.new({
          token: credential_user.token,
          user: credential_user
        })
      end
    end

    #USERS!!!

    field :createUser, Types::UserType, null: false do
      argument :user, Types::AuthProviderUsernameInput, required: true
      argument :email, String, required: true
      argument :number, String, required: false
    end

    def create_user(user:, email:, number:nil)
      User.create!(
          email: email,
          number: number,
          username: user[:username],
          password: user[:password]
        )
        UserNotifier.send_signup_email(user).deliver
    end

    field :updateUser, Types::UserType, null: false do
      argument :token, String, required: true
      argument :username, String, required: false
      argument :password, String, required: false
      argument :email, String, required: false
      argument :number, String, required: false
   end

    def update_user(token:, username:nil, password:nil, email:nil, number:nil)
      current_user = User.find_by(token: token)
      user_params = {email: email,
                     number: number,
                     username: username,
                     password: password}.compact

      if current_user.update(user_params)
        current_user
      end
      UserNotifier.send_update_email(user).deliver
      
      def reset_password(user:)
        credential_user = User.find_by_username(user[:username])
        if credential_user && credential_user.authenticate(user[:email])
          OpenStruct.new({
            token: credential_user.email,
            user: credential_user
          })
        end
        UserNotifier.send_reset_password_email(user).deliver
      end
    end

    field :blockUser, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :user_id, ID, required: true
    end

    def block_user(token:, user_id:)
      current_user = User.find_by(token: token)

      connections = Connection.where(contact_id:current_user.id, user_id:user_id)
      connections.destroy_all

      connections = Connection.where(user_id:current_user.id, contact_id:user_id)
      connections.destroy_all

      Connection.create!(
            user_id: current_user.id,
            contact_id: user_id,
            card_id: -1
          )

    end

    field :destroyUser, Types::NullType, null: true do
      argument :token, String, required: true
    end

    def destroy_user(token:)
      current_user = User.find_by(token: token)
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

    #CARDS!!!

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
    end

    def create_card(token:, owned:true, card_name:, display_name:nil, name:, 
                    business_name:nil, number:nil, email:nil, address:nil, birth_date:nil,
                    twitter:nil, facebook:nil, linked_in:nil, instagram:nil)
      current_user = User.find_by(token: token)
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
          name: card_name,
          display_name: display_name || card_name,
          person_name: name,
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

      if not owner
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
      current_user = User.find_by(token: token)
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

      card_params = {name: card_name, 
                     display_name: display_name, 
                     person_name: name, 
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
      current_user = User.find_by(token: token)
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

    #CONNECTIONS!!!

    field :createConnection, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :card_id, ID, required: true
    end

    def create_connection(token:, card_id:)
      # TODO: Add QR Code support
      current_user = User.find_by(token: token)
      card = Card.find(card_id)
      print card.user_id
      if card
          Connection.create!(
            user_id: current_user.id,
            contact_id: card.user_id,
            card_id: card.id
          )
      end
    end

    field :updateConnection, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :id, ID, required: true
      argument :card_id, ID, required: true
    end

    def update_connection(token:, id:, card_id:)
      current_user = User.find_by(token: token)
      return unless current_user

      connection = Connection.find_by(id:id, contact_id:current_user.id)
      return unless connection

      card = Card.find_by(id:card_id, user_id:current_user.id)
      return unless card

      if connection.update(card_id: card.id)
          connection
      end
    end

    field :destroyConnection, Types::NullType, null: true do
      argument :token, String, required: true
      argument :id, ID, required: true    
    end

    def destroy_connection(token:, id:)
      current_user = User.find_by(token: token)
      return unless current_user

      connection = Connection.find_by(id:id, contact_id:current_user.id) || Connection.find_by(id:id, user_id:current_user.id)
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
    end

    #LOGS!!!

    # field :createLog, Types::LogType, null: false do
    #   argument :user, Types::UserType, required: true
    #   argument :contact, Types::UserType, required: false
    #   argument :card, Types::CardType, required: true
    #   argument :date, String, required: false
    #   argument :text, String, required: true
    # end

    # field :updateLog, Types::LogType, null: false do
    #   argument :user, Types::UserType, required: true
    #   argument :contact, Types::UserType, required: false
    #   argument :card, Types::CardType, required: true
    #   argument :date, String, required: false
    #   argument :text, String, required: false
    # end

    # def create_log(token:, card_id:)
    #   current_user = User.find_by(token: token)
    #   log = Log.find(log_id)
    #   print log.user_id
    #   if log
    #       Log.create!(
    #         user_id: current_user.id,
    #         contact_id: card.user_id,
    #         card_id: card.id
    #       )
    #   end
    # end

    # def update_log(token:, card_id:)
    #   current_user = User.find_by(token: token)
    #   return unless current_user

    #   log = Log.find_by(id:id, contact_id:current_user.id)
    #   return unless log

    #   card = Card.find_by(id:card_id, user_id:current_user.id)
    #   return unless card

    #   if log.update(card_id: card.id)
    #       log
    #   end
    # end

    # def destroy_log
    #   current_user = User.find_by(token: token)
    #   return unless current_user

    #   log = Log.find_by(id:id, contact_id:current_user.id)
    #   return unless log

    #   card = Card.find_by(id:card_id, user_id:current_user.id)
    #   return unless card

    #   if log.destroy(card_id: card.id)
    #       log
    #   end
    # end
    
  end
end