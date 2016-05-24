TOP_CATEGORIES = %w(Infrastructe Event Business Market )
LOWER_CATEGORIES = %w(Sale Website Farm\ Market Roadside\ Stand Party Networking\ Event)
FactoryGirl.define do
  factory :category do
    name 'MyString'
  end
  
  factory :nested_category do
    name { |x| x.parent.nil? ? TOP_CATEGORIES[ rand( TOP_CATEGORIES.length ) ] : LOWER_CATEGORIES[rand( LOWER_CATEGORIES.length) ] }
  end

  factory :category_tag do
    nested_category do
      t = FactoryGirl.create( :nested_category )
      FactoryGirl.create( :nested_category, parent: t )
    end
    association :location
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
    is_approved true
    sequence(:email) { |n| "citizen#{n}@youngagrarians.org" }
    after( :create ) do |a|
      FactoryGirl.create( :category_tag, location: a )
    end
  end
end
