class Card < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :author, :class_name => 'User'
  belongs_to :address, optional: true

  validates :email, 'valid_email_2/email': true

  def number=(number)
    phone_object = TelephoneNumber.parse(number, :us)
    self[:number] = phone_object.national_number if phone_object.valid?
  end

end
