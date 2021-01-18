# frozen_string_literal: true

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
    url = Shortlink.where('expires_at >= ? ', Time.now).or(Shortlink.where(expires_at: nil)).find_by(token: @token)
    @decoded_auth_token ||= JsonWebToken.decode(url.jwt) if url
  end
end
