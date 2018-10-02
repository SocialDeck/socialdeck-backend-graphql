Types::CardType = GraphQL::ObjectType.define do
  name 'Card'

  field :id, !types.ID
  field :user, -> { Types::UserType }, property: :user
  field :author_id, -> { Types::UserType }, property: :user
  field :name, types.String
  field :display_name, types.String
  field :person_name, types.String
  field :business_name, types.String
  field :address_id, -> { Types::AddressType }, property: :address
  field :number, types.String
  field :email, types.String
  field :birth_date, Types::DateTimeType
  field :twitter, types.String
  field :linked_in, types.String
  field :facebook, types.String
  field :instagram, types.String

end