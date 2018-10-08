class User < ApplicationRecord
  has_secure_token
  has_secure_password

  attr_accessible :username, :password, :password_confirmation

  has_many :contacts, :class_name => 'Connection', dependent: :destroy
  has_many :cards, dependent: :destroy
  has_many :logs, dependent: :destroy

  has_many :authored_cards, :class_name => 'Card', :foreign_key => 'author_id', dependent: :destroy
  has_many :subscibers, :class_name => 'Connection', :foreign_key => 'contact_id', dependent: :destroy

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, 'valid_email_2/email': true
  validates :password, presence: true, confirmation: true


  def number=(number)
    phone_object = TelephoneNumber.parse(number, :us)
    self[:number] = phone_object.national_number if phone_object.valid?
  end
end
