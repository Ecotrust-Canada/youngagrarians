namespace :data do
  desc 'Remove all locations that are in the market category'
  task remove_market_locations: :environment do
    category = Category.where(name: 'Market').first
    Location.where(category_id: category.id).delete_all
  end
end
