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

    field :card, Types::CardType, null: false do
      argument :id, ID, required: true
      argument :token, String, required: true
    end
    
    field :cards, [Types::CardType], null: true do
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
      if connection
        Card.find(id)
      end
    end    

    def cards(token:)
      current_user = User.find_by(token: token)
      Card.where(author_id: current_user.id, user_id: nil)
    end     

    def users
      User.all
    end

    def contacts(token:)
      current_user = User.find_by(token: token)
      Card.where(id: Connection.where(user_id: current_user.id).pluck(:card_id))
    end
  end
end
