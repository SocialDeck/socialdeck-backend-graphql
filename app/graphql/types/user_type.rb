Types::UserType = GraphQL::ObjectType.define do
  name 'User'

  field :id, !types.ID
  field :username, !types.String
  field :email, types.String
  field :number, types.String
end