class User < ApplicationRecord
  has_secure_token
  has_secure_password

  has_many :contacts, :class_name => 'Card'
  has_many :cards
  has_many :logs

  has_many :authored_cards, :class_name => 'Card', :foreign_key => 'author_id'
  has_many :subscibers, :class_name => 'Connection', :foreign_key => 'contact_id'

end
