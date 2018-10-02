class Mutations::CreateUser < GraphQL::Function
  argument :user, !Types::AuthProviderUsernameInput
  argument :email, !types.String
  argument :number, types.String

  type Types::UserType

  def call(_obj, args, _ctx)
    User.create!(
      email: args[:email],
      number: args[:number],
      username: args[:user][:username],
      password: args[:user][:password]
    )
  end
end