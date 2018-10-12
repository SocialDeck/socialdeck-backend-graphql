module Types
  class AddressType < Types::BaseObject
    field :id, ID, null: false
    field :address1, String, null: true
    field :address2, String, null: true
    field :city, String, null: true
    field :state, String, null: true
    field :postal_code, String, null: true
  end
end