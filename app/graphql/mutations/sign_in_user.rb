class Mutations::SignInUser < GraphQL::Function
  # define the arguments this field will receive
  argument :user, !Types::AuthProviderUsernameInput

  # define what this field will return
  type do
    name 'SigninPayload'

    field :token, types.String
    field :user, Types::UserType
  end

  # resolve the field's response
  def call(obj, args, ctx)
    input = args[:user]
    puts input
    return unless input
    puts input
    user = User.find_by(username: input[:username])
    return unless user
    return unless user.authenticate(input[:password])

    OpenStruct.new({
      token: user.token,
      user: user
    })
  end
end