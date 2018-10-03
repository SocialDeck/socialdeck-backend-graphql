module Types
  class QueryType < Types::BaseObject

    field :users, [Types::UserType], null: true 
    field :contacts, [Types::CardType], null: true
    field :logs, [Types::LogType], null: true do
      argument :card_id, ID, required: true
    end
    field :card, Types::CardType, null: false do
      argument :id, ID, required: true
    end
    field :cards, [Types::CardType], null: true

    # Then provide an implementation:
    def logs(card_id:)
      Log.where(card_id: card_id, user_id: context[:current_user].id)
    end

    def card(id:)
      connection = Connection.find_by(user_id: context[:current_user].id, card_id: id)
      if connection
        Card.find(id)
      end
    end    

    def cards
      Card.where(author_id: context[:current_user].id, user_id: nil)
    end     

    def users
      User.all
    end

    def contacts
      Card.where(id: Connection.where(user_id: context[:current_user].id).pluck(:card_id))
    end
  end
end
