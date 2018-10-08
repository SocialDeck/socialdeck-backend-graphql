class AuthorizedCardRequest
  prepend SimpleCommand

  def initialize(token)
    @token = token
  end

  def call
    card
  end

  private

  def card
    @card ||= Card.find(decoded_auth_token[:card_id]) if decoded_auth_token
    @card || errors.add(:token, 'Invalid token') && nil
  end

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(@token)
  end
end