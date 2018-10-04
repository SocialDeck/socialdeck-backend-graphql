module Types
  class LinkType < Types::BaseObject
    field :id, ID, null: false
    field :user, Types::UserType, null: false
    field :contact, Types::UserType, null: true
    field :card, Types::CardType, null: false
  end
end