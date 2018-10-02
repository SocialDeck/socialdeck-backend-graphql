module Types
  class MutationType < Types::BaseObject
  graphql_name "Mutation"

  field :createUser, function: Mutations::CreateUser.new
  field :signinUser, function: Mutations::SignInUser.new
  end
end
