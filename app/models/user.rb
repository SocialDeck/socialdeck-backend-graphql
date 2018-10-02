class User < ApplicationRecord
  has_secure_token
  has_secure_password

  has_many :contacts, :class_name => 'Connection'
  has_many :cards
  has_many :logs

  has_many :authored_cards, :class_name => 'Card', :foreign_key => 'author_id'
  has_many :subscibers, :class_name => 'Connection', :foreign_key => 'contact_id'

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, 'valid_email_2/email': true

  def number=(number)
    phone_object = TelephoneNumber.parse(number, :us)
    self[:number] = phone_object.national_number if phone_object.valid?
  end
end
