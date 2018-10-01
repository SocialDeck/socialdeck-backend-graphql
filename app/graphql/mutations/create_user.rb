class Mutations::CreateUser < GraphQL::Function
  AuthProviderInput = GraphQL::InputObjectType.define do
    name 'AuthProviderSignupData'

    argument :user, Types::AuthProviderUsernameInput
  end

  argument :email, !types.String
  argument :number, types.String
  argument :authProvider, !AuthProviderInput

  type Types::UserType

  def call(_obj, args, _ctx)
    User.create!(
      email: args[:email],
      username: args[:authProvider][:user][:username],
      password: args[:authProvider][:user][:password]
    )
  end
end