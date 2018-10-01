FactoryBot.define do
  factory :card do
    user { nil }
    author { nil }
    name { "MyString" }
    display_name { "MyString" }
    person_name { "MyString" }
    business_name { "MyString" }
    address { nil }
    number { "MyString" }
    email { "MyString" }
    birth_date { "2018-10-01" }
    twitter { "MyString" }
    linked_in { "MyString" }
    facebook { "MyString" }
    instagram { "MyString" }
  end
end
