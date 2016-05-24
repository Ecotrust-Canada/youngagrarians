class AttachAccountToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :account_id, :integer
  end
end
