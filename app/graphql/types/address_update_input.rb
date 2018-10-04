module Types
  class AddressUpdateInput < Types::BaseInputObject
    argument :address1, String, "Street Address", required: false
    argument :address2, String, "Apt/Suite/Bld#", required: false
    argument :city, String, "City", required: false
    argument :state, String, "State", required: false
    argument :postal_code, String, "Zip Code", required: false
  end
end