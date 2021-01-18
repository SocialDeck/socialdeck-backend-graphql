# frozen_string_literal: true

module Types
  class NullType < Types::BaseObject
    field :message, String, null: false
  end
end
