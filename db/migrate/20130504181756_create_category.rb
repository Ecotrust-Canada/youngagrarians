class CreateCategory < ActiveRecord::Migration
  def change
    create_table :categories do |c|
      c.string :name
      c.timestamps null: false
    end
  end
end
