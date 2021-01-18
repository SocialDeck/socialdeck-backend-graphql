# frozen_string_literal: true

module Types
  class TokenType < Types::BaseObject
    field :user, Types::UserType, null: false
    field :token, ID, null: false
  end
end
