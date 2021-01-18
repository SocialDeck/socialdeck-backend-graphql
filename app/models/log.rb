# frozen_string_literal: true

class Log < ApplicationRecord
  belongs_to :user
  belongs_to :contact, optional: true
  belongs_to :card
end
