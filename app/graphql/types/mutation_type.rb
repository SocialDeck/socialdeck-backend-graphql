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

    field :createConnection, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :card_id, ID, required: true
    end

    field :blockUser, Types::LinkType, null: true do
      argument :token, String, required: true
      argument :user_id, ID, required: true
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
  end
end
