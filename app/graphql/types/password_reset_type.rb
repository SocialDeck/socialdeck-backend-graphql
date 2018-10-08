module Types
  class PasswordResetType < Types::BaseObject
    argument :username, String, "Username for user", required: true
    argument :password, String, "User's password", required: true
    argument :password_confirmation, String, "Confirm Password", required: true
  end
end