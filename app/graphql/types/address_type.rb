module Types
  class AddressType < Types::BaseObject
    field :id, ID, null: false
    field :address1, String, null: false
    field :address2, String, null: true
    field :city, String, null: false
    field :state, String, null: false
    field :postal_code, String, null: false
  end
end