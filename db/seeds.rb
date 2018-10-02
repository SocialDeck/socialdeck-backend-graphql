# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'faker'

def valid_number
  number = Faker::PhoneNumber.cell_phone
  while TelephoneNumber.invalid?(number, :us)
    number = Faker::PhoneNumber.cell_phone
  end
  number
end


10.times do
  Address.create!(
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
    password: "user",
    email: Faker::Internet.email,
    number: valid_number
  )
end

10.times do
  user = User.find(User.pluck(:id).sample)
  Card.create!(
    name: Faker::Name.name,
    display_name: Faker::Military.air_force_rank,
    person_name: Faker::Name.name,
    business_name: rand < 0.3 ? Faker::Bank.name : nil,
    number: user.number,
    email: user.email,
    user_id: user.id,
    author_id: user.id,
    address_id: Address.pluck(:id).sample,
    birth_date: Faker::Date.birthday(18, 65),
    twitter: rand < 0.3 ? "https://twitter.com/" + user.username : nil,
    linked_in: rand < 0.3 ? Faker::Name.name : nil,
    facebook: rand < 0.3 ? Faker::Space.galaxy : nil,
    instagram: rand < 0.3 ? Faker::GameOfThrones.house : nil
  )
end

10.times do
  user = User.find(User.pluck(:id).sample)
  Card.create!(
    name: Faker::Name.name,
    display_name: Faker::Military.air_force_rank,
    person_name: Faker::Name.name,
    business_name: rand < 0.3 ? Faker::Bank.name : nil,
    number: valid_number,
    email: Faker::Internet.email,
    address_id: Address.pluck(:id).sample,
    author_id: user.id,
    birth_date: Faker::Date.birthday(18, 65),
    twitter: rand < 0.3 ? "https://twitter.com/" + user.username : nil,
    linked_in: rand < 0.3 ? Faker::Name.name : nil,
    facebook: rand < 0.3 ? Faker::Space.galaxy : nil,
    instagram: rand < 0.3 ? Faker::GameOfThrones.house : nil
  )
end

10.times do
  user = User.find(User.pluck(:id).sample)
  card = Card.find(Card.pluck(:id).sample)
  Connection.create!(
    user_id:user.id,
    contact_id: card.user_id,
    card_id: card.id
  )
end