module Types
  class QueryType < Types::BaseObject

    field :users, [Types::UserType], null: true 

    field :contacts, [Types::CardType], null: true do
      argument :token, String, required: true
    end

    field :logs, [Types::LogType], null: true do
      argument :card_id, ID, required: true
      argument :token, String, required: true
    end

    field :card, Types::CardType, null: true do
      argument :id, ID, required: true
      argument :token, String, required: true
    end

    field :authored_cards, [Types::CardType], null: true do
      argument :token, String, required: true
    end

    field :owned_cards, [Types::CardType], null: true do
      argument :token, String, required: true
    end

    field :blocked_Users, [Types::UserType], null: true do
      argument :token, String, required: true
    end

    # Then provide an implementation:
    def logs(card_id:, token:)
      current_user = User.find_by(token: token)
      Log.where(card_id: card_id, user_id: current_user.id)
    end

    def card(id:, token:)
      current_user = User.find_by(token: token)
      connection = Connection.find_by(user_id: current_user.id, card_id: id)
      owned_card = Card.find_by(user_id: current_user.id, id: id)
      authored_card = Card.find_by(author_id: current_user.id, id: id)
      if connection || owned_card || authored_card
        Card.find(id)
      end
    end    

    def authored_cards(token:)
      current_user = User.find_by(token: token)
      Card.where(author_id: current_user.id, user_id: nil)
    end     

    def owned_cards(token:)
      current_user = User.find_by(token: token)
      Card.where(user_id: current_user.id)
    end

    def users
      User.all
    end

    def contacts(token:)
      current_user = User.find_by(token: token)
      Card.where(id: Connection.where(user_id: current_user.id).pluck(:card_id)).where.not(id: -1)
    end

    def blocked_users(token:)
      current_user = User.find_by(token: token)
      User.where(id: Connection.where(card_id: -1, user_id: current_user.id).pluck(:contact_id))
    end
  end
end
