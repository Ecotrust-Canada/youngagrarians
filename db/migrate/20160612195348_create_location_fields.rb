class CreateLocationFields < ActiveRecord::Migration
  def change
    create_table :location_fields do |t|
      t.column :comment, :string
      t.column :boolean_value, :integer, null: false
      t.column :field_id, :integer, null: false
      t.column :location_id, :integer, null: false
      t.column :serial_data, :text
    end
    add_column :locations, :land_size, :string # allow decimals, units
  end
end
