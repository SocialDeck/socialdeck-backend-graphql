module Types
  class MutationType < Types::BaseObject

    field :login, Types::TokenType, null: true do
      argument :user, Types::AuthProviderUsernameInput, required: true
    end
    
    field :createUser, Types::UserType, null: false do
      argument :user, Types::AuthProviderUsernameInput, required: true
      argument :email, String, required: true
      argument :number, String, required: false
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

    def create_user(user:, email:, number:nil)
      User.create!(
          email: email,
          number: number,
          username: user[:username],
          password: user[:password]
        )
    end
  #UPDATE FEATURES
    field :updateUser, Types::UserType, null: false do
      argument :user, Types::AuthProviderUsernameInput, required: true
      argument :email, String, required: true
     argument :number, String, required: false
   end

    field :updateCard, Types::CardType, null: true do
      argument :token, String, required: true
      argument :owner, Boolean, required: true
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

     field :updateConnection, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :card_id, ID, required: true
    end

    def update_connection(token:, card_id:)
      current_user = User.find_by(token: token)
      card = Card.find(card_id)
      print card.user_id
      if card.update
          Connection.update!(
            user_id: current_user.id,
            contact_id: card.user_id,
            card_id: card.id
          )
      end
    end

    #LOG CREATE & UPDATE

    field :createLog, Types::LogType, null: false do
      argument :user, Types::UserType, required: true
      argument :contact, Types::UserType, required: false
      argument :card, Types::CardType, required: true
      argument :date, String, required: false
      argument :text, String, required: false
    end

    field :updateLog, Types::LogType, null: false do
      argument :user, Types::UserType, required: true
      argument :contact, Types::UserType, required: false
      argument :card, Types::CardType, required: true
      argument :date, String, required: false
      argument :text, String, required: false
    end

    def create_log(token:, card_id:)
      current_user = User.find_by(token: token)
      log = Log.find(log_id)
      print log.user_id
      if log
          Log.create!(
            user_id: current_user.id,
            contact_id: card.user_id,
            card_id: card.id
          )
      end
    end

    def update_log(token:, card_id:)
      current_user = User.find_by(token: token)
      log = Log.find(log_id)
      print log.user_id
      if log.update
          Log.update!(
            user_id: current_user.id,
            contact_id: card.user_id,
            card_id: card.id
          )
      end
    end

  end
end
