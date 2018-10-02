Types::AddressType = GraphQL::ObjectType.define do
  name 'Address'

  field :id, !types.ID
  field :address1, types.String
  field :address2, types.String
  field :city, types.String
  field :state, types.String
  field :postal_code, types.String

end