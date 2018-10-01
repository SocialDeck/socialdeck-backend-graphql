FactoryBot.define do
  factory :log do
    user { nil }
    contact { nil }
    date { "2018-10-01" }
    text { "MyString" }
  end
end
