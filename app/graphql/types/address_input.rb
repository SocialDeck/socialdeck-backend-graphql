module Types
  class AddressInput < Types::BaseInputObject
    argument :address1, String, "Street Address", required: true
    argument :address2, String, "Apt/Suite/Bld#", required: false
    argument :city, String, "City", required: true
    argument :state, String, "State", required: true
    argument :postal_code, String, "Zip Code", required: true
  end
end