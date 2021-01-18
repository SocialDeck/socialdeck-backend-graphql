# frozen_string_literal: true

module Types
  class LogType < Types::BaseObject
    field :id, ID, null: false
    field :user, Types::UserType, null: false
    field :contact, Types::UserType, null: false
    field :card, Types::CardType, null: true
    field :date, Types::DateTimeType, null: false
    field :text, String, null: false
  end
end
