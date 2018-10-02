class Connection < ApplicationRecord
  belongs_to :user
  belongs_to :contact, :class_name => 'User', optional: true
  belongs_to :card
end
