module Mutations
  class Login < Mutations::BaseMutation
    null true

    argument :user, Types::AuthProviderUsernameInput, required: true

    field :login, Types::TokenType, null: true

    def resolve(user:)
      credential_user = User.find_by_username(user[:username])
      raise GraphQL::ExecutionError, 'User does not exist' unless credential_user

      if credential_user.authenticate(user[:password])
        OpenStruct.new({
                        token: JsonWebToken.encode(user_id: credential_user.id),
                        user: credential_user
                      })
      else
        raise GraphQL::ExecutionError, 'Invalid Password'
      end
    end
  end
end
