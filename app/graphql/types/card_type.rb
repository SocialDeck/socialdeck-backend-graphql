module Types
  class CardType < Types::BaseObject
    field :id, ID, null: false
    field :user, Types::UserType, null: true
    field :author, Types::UserType, null: false
    field :name, String, null: false
    field :display_name, String, null: false
    field :person_name, String, null: false
    field :business_name, String, null: true
    field :address, Types::AddressType, null: true
    field :number, String, null: true
    field :email, String, null: true
    field :birth_date, Types::DateTimeType, null: true
    field :twitter, String, null: true
    field :linked_in, String, null: true
    field :facebook, String, null: true
    field :instagram, String, null: true
    field :verified, Boolean, null: false

    def verified
      !!object.user_id
    end
  end
end