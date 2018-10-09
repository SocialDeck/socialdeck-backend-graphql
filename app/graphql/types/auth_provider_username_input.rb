module Types
  class AuthProviderUsernameInput < Types::BaseInputObject
    argument :username, String, "Username for user", required: true
    argument :password, String, "User's password", required: true
    argument :remember, Boolean, "Remember for two weeks", required: false
  end
end