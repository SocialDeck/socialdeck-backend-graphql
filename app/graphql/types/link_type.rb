module Types
  class LinkType < Types::BaseObject
    field :id, ID, null: false
    field :user, Types::UserType, null: false
    field :contact, Types::UserType, null: true
    field :card, Types::CardType, null: false
    field :favorite, Boolean, null: false
    field :mutual, Boolean, null: false

    def mutual
      connection = Connection.find_by(user_id:object.contact.id, contact_id:object.user.id)
      !!connection
    end
  end
end
