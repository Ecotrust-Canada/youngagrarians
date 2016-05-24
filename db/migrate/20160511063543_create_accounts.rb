class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.column :email, :string, null: false
      t.column :password, :string, null: false
      t.timestamps null: false
    end
  end
end
