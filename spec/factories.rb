FactoryGirl.define do
  factory :category do
    name 'MyString'
  end

  factory :user do
    first_name 'John'
    sequence(:last_name) { |n| "Doe-#{n}" }
    email { "#{first_name}_#{last_name}@youngagrarians.org" }
    password 'secret12'
    username { "#{first_name}_#{last_name}" }
  end

  factory :location do
    sequence(:name) { |n| "Location #{n}" }
    sequence(:street_address) { |n| "#{n} Fake Street" }
    city 'Vancouver'
    province 'BC'
    country 'CAN'
    postal 'V5Y0E8'
    content 'Some content'
    bioregion 'Vancouver'
    phone '6045556669'
    url 'tapandbarrel.ca'
    description 'Apparently awesome pub place'
    is_approved false
    category { Category.first }
    sequence(:email) { |n| "citizen#{n}@youngagrarians.org" }
  end
end
