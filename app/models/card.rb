# frozen_string_literal: true

class Card < ApplicationRecord
  include PgSearch
  belongs_to :user, optional: true
  belongs_to :author, class_name: 'User'
  belongs_to :address, optional: true

  has_many :connections, dependent: :destroy
  has_many :logs, dependent: :destroy

  pg_search_scope :search,
                  against: [:name],
                  using: {
                    trigram: {
                      threshold: 0.2
                    }
                  }

  def number=(number)
    self[:number] = ActionController::Base.helpers.number_to_phone(number, area_code: true)
  end
end
