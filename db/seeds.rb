# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'faker'

10.times do
  Address.create(
    address1: Faker::Address.street_address,
    address2: Faker::Address.secondary_address,
    city: Faker::Address.city,
    state: Faker::Address.state,
    postal_code: Faker::Address.zip
  )
end

10.times do
  User.create(
    username: Faker::Internet.username, 
    password: Faker::Internet.password(8),
    email: Faker::Internet.email,
    number: Faker::PhoneNumber.cell_phone
  )
end

10.times do
  Card.create(
    name: Faker::Name.name,
    display_name: Faker::Military.air_force_rank,
    person_name: Faker::Name.name,
    business_name: Faker::Bank.name,
    number: Faker::Internet.password(8),
    email: Faker::Internet.email,
    birth_date: Faker::Date.birthday(18, 65),
    twitter: Faker::Twitter.user,
    linked_in: Faker::Name.name,
    facebook: Faker::Space.galaxy,
    instagram: Faker::GameOfThrones.house
  )
end
