require 'rqrcode'

module Types
  class QueryType < Types::BaseObject

    # User Endpoints
    
    field :users, [Types::UserType], null: true 
        
    def users
      User.all
    end

    field :blocked_Users, [Types::UserType], null: true do
      argument :token, String, required: true
    end

    def blocked_users(token:)
      current_user = AuthorizeUserRequest.call(token).result
      User.where(id: Connection.where(card_id: -1, contact_id: current_user.id).pluck(:user_id))
    end

    # Card Queries

    field :card, Types::CardType, null: true do
      argument :card_token, String, required: true
    end

    def card(card_token:)
      card = AuthorizedCardRequest.call(card_token).result
    end    

    field :share_card, String, null: true do
      argument :token, String, required: true
      argument :id, ID, required: true
    end

    def share_card(token:, id:)
      current_user = AuthorizeUserRequest.call(token).result
      owned_card = Card.find_by(user_id: current_user.id, id: id)
      token = AuthenticateCard.call(current_user.id, owned_card.id).result
      RQRCode::QRCode.new("https://socialdeck-3c370.firebaseapp.com/contacts/#{token}").as_svg
    end 

    field :authored_cards, [Types::CardType], null: true do
      argument :token, String, required: true
    end

    def authored_cards(token:)
      current_user = AuthorizeUserRequest.call(token).result
      Card.where(author_id: current_user.id, user_id: nil)
    end     

    field :owned_cards, [Types::CardType], null: true do
      argument :token, String, required: true
    end

    def owned_cards(token:)
      current_user = AuthorizeUserRequest.call(token).result
      Card.where(user_id: current_user.id)
    end

    field :contacts, [Types::CardType], null: true do
      argument :token, String, required: true
      argument :search, String, required: false
    end

    def contacts(token:, search:nil)
      current_user = AuthorizeUserRequest.call(token).result
      if search
        Card.where(id: Connection.where(user_id: current_user.id).pluck(:card_id)).where.not(id: -1).search(search)
      else
        Card.where(id: Connection.where(user_id: current_user.id).pluck(:card_id)).where.not(id: -1)
      end
    end

    # Connection Queries

    field :subscibers, [Types::LinkType], null: true do
      argument :token, String, required: true
    end

    def subscibers(token:)
      current_user = AuthorizeUserRequest.call(token).result
      Connection.where(contact_id: current_user.id).where.not(card_id: -1)
    end

    # field :logs, [Types::LogType], null: true do
    #   argument :card_id, ID, required: true
    #   argument :token, String, required: true
    # end

    # def logs(card_id:, token:)
    #   current_user = AuthorizeUserRequest.call(token).result
    #   Log.where(card_id: card_id, user_id: current_user.id)
    # end    

  end
end
