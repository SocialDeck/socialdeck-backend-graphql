class AuthenticateCard
  prepend SimpleCommand
  attr_accessor :card_id, :user_id

  #this is where parameters are taken when the command is called
  def initialize(user_id, card_id)
    @card_id = card_id
    @user_id = user_id
  end
  
  #this is where the result gets returned
  def call
    if card
      jwt = JsonWebToken.encode(card_id: card.id, user_id:@user_id)
      if card.user && card.user.id == @user_id
        Shortlink.where(jwt: jwt).where("expires_at < ? ", Time.now).destroy_all
        url = Shortlink.create(jwt: jwt, expires_at: 48.hours.from_now)
      else
        url = Shortlink.find_or_create_by(jwt: jwt)
      end
      url.token
    end
  end

  private

  def card
    connection = Connection.find_by(user_id: user_id, card_id: card_id)
    owned_card = Card.find_by(user_id: user_id, id: card_id)
    authored_card = Card.find_by(author_id: user_id, id: card_id)
    if connection || owned_card || authored_card
      card = Card.find(card_id)
    end

    return card if card

    errors.add :user_authentication, 'Invalid credentials'
    nil
  end
end