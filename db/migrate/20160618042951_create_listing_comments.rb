class CreateListingComments < ActiveRecord::Migration
  def change
    create_table :listing_comments do |t|
      t.column :name, :string
      t.column :email, :string
      t.column :location_id, :integer, null: false
      t.column :body, :text
      t.column :is_spam, :boolean, null: false, default: false

      t.timestamps null: false
    end
  end
end
