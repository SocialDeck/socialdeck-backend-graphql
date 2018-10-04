module Types
  class NullType < Types::BaseObject
    field :message, String, null: false
  end
end
