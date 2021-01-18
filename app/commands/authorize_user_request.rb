# frozen_string_literal: true

class AuthorizeUserRequest
  prepend SimpleCommand

  def initialize(token)
    @token = token
  end

  def call
    user
  end

  private

  def user
    @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
    @user || errors.add(:token, 'Invalid token') && nil
  end

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(@token)
  end
end
