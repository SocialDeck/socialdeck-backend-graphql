# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }"])
#   Character.create(name: 'Luke', movie: movies.first)
require 'faker'
require 'csv'


def valid_number
  number = Faker::PhoneNumber.cell_phone
  while TelephoneNumber.invalid?(number, :us)
    number = Faker::PhoneNumber.cell_phone
  end
  number
end

User.create(
  id: -1,
  username: "blocked", 
  password: Faker::Internet.password,
  email: "blocked@socialdeck.xyz",
)

Card.create!(
  id:-1,
  name: "Blocked",
  display_name: "Blocked",
  person_name: "Blocked",
  author_id: -1,
)

CSV.foreach('db/MOCK_DATA.csv', headers: true) do |row|
  row_hash = row.to_h
  puts row_hash
  user_params = {
    username: row_hash["username"],
    password: "user",
    email: row_hash["personal_email"],
    number: row_hash["personal_number"]
  }

  if User.all.count < 200
    user = User.create!(user_params)
    user_id = user.id
    author_id = user.id
  else
    user = User.find(User.where.not(id: -1).pluck(:id).sample)
    user_id = nil
    author_id = user.id
  end

  if row_hash["address1"]
    address_params = {
      address1: row_hash["address1"],
      address2: row_hash["address2"],
      city: row_hash["city"],
      state: row_hash["state"],
      postal_code: row_hash["postal_code"]    
    }

    address = Address.create!(address_params)
    address_id = address_id
  else
    address_id = nil
  end

  personal_card_params = {
    name: "Personal",
    display_name: "Personal",
    person_name: row_hash["first_name"] + ' ' + row_hash["last_name"],
    number: row_hash["personal_number"],
    email: row_hash["personal_email"],
    user_id: user_id,
    author_id: author_id,
    address_id: address_id,
    birth_date: row_hash["birth_date"],
    twitter: rand < 0.3 ? "https://twitter.com/" + row_hash["username"] : nil,
    linked_in: rand < 0.3 ? "https://linkedin.com/in/" + row_hash["username"]: nil,
    facebook: rand < 0.3 ? "https://facebook.com/" + row_hash["username"] : nil,
    instagram: rand < 0.3 ? "https://instagram.com/" + row_hash["username"] : nil    
  }
  personal_card = Card.create!(personal_card_params)

  if user_id.nil?
    Connection.create!(
      user_id:author_id,
      contact_id: nil,
      card_id: personal_card.id
    )
  end

  if row_hash["business_name"] && !user_id.nil?
    work_card_params = {
      name: "Work",
      display_name: "Work",
      person_name: row_hash["first_name"] + ' ' + row_hash["last_name"],
      business_name: row_hash["business_name"],        
      number: row_hash["work_number"],
      email: row_hash["work_email"],
      user_id: user_id,
      author_id: author_id   
    }
    work_card = Card.create!(work_card_params)

    if user_id.nil?
      Connection.create!(
        user_id:author_id,
        contact_id: nil,
        card_id: work_card.id
      )
    end
  end
end

User.all.each do |user| 
  next if user.id == -1  

  50.times do
    contact = User.find(User.where.not(id: user.id).pluck(:id).sample)
    while contact.cards.count == 0
      contact = User.find(User.where.not(id: user.id).pluck(:id).sample)
    end
    card = Card.find(contact.cards.pluck(:id).sample)

    if !Connection.find_by(user_id:user.id, contact_id:contact.id, card_id: card.id)
      Connection.create!(
        user_id:user.id,
        contact_id: contact.id,
        card_id: card.id
      )
    end
  end

  2.times do
    contact = User.find(User.where.not(id:user.id).pluck(:id).sample)
    connections = Connection.where(user_id: user.id, contact_id: contact.id)
    connections.destroy_all
    Connection.create(
      user_id:user.id,
      contact_id: contact.id,
      card_id: -1
    )
  end
end

# 10.times do
#   connection = Connection.find(Connection.pluck(:id).sample)
#   Log.create!(
#     user_id:connection.user_id,
#     contact_id: connection.contact_id,
#     card_id: connection.card_id,
#     date: Time.now + [1.day, 2.day, 3.day].sample,
#     text: Faker::GameOfThrones.house
#   )
# end