class Card < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :author, :class_name => 'User'
  belongs_to :address
end
