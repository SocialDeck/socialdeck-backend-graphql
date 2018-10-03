module Types
  class MutationType < Types::BaseObject

    field :login, Types::TokenType, null: true do
      argument :user, Types::AuthProviderUsernameInput, required: true
    end
    
    field :createUser, Types::UserType, null: false do
      argument :user, Types::AuthProviderUsernameInput, required: true
      argument :email, String, required: true
      argument :number, String, required: false
    end


    def login(user:)
      credential_user = User.find_by_username(user[:username])
      if credential_user && credential_user.authenticate(user[:password])
        OpenStruct.new({
          token: credential_user.token,
          user: credential_user
        })
      end
    end

    def create_user(user:, email:, number:nil)
      User.create!(
          email: email,
          number: number,
          username: user[:username],
          password: user[:password]
        )
    end
  end
end
