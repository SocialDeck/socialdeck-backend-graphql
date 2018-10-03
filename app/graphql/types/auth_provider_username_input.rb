module Types
  class AuthProviderUsernameInput < Types::BaseInputObject
    argument :username, String, "Username for user", required: true
    argument :password, String, "User's password", required: true
  end
end