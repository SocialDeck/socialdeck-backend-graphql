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
    JsonWebToken.encode(card_id: card.id) if card
  end

  private

  def card
    connection = Connection.find_by(user_id: user_id, card_id: card_id)
    owned_card = Card.find_by(user_id: user_id, id: card_id)
    authored_card = Card.find_by(author_id: user_id, id: card_id)
    if connection || owned_card || authored_card
      card = Card.find(card_id)
    end

    print card
    return card if card

    errors.add :user_authentication, 'Invalid credentials'
    nil
  end
end