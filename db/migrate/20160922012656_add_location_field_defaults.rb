class AddLocationFieldDefaults < ActiveRecord::Migration
  def up
    Location.all.each do |location|
      if location.land_listing?
        location.location_fields.each do |field|
          if field.field_id == 4
            if field.serial_data == '[]'
              field.serial_data = [{"value":"Not used for agriculture"},{"value":"Vegetable"},{"value":"Livestock"},{"value":"Grain"},{"value":"Seed"},{"value":"Hay \u0026 Forage"},{"value":"Orchard/Fruit"},{"value":"Mixed"},{"value":"Other"}].to_json
              field.save!
            end
          elsif field.field_id == 21
            if field.serial_data == '[]'
              field.serial_data = [{"value":"Certified Organic"},{"value":"Organic"},{"value":"Conventional"},{"value":"Other"}].to_json
              field.save!
            end
          elsif field.field_id == 23
            if field.serial_data == '[]'
              field.serial_data = [{"value":"Texture"},{"value":"Rocky soil"},{"value":"Sloping"},{"value":"Thick topsoil"},{"value":"Slope orientation and degree of slope (specify)"},{"value":"General fertility (nutrients)"},{"value":"Soil grittiness"},{"value":"Good drainage"},{"value":"Unknown"}].to_json
              field.save!
            end
          elsif field.field_id == 5
            if field.serial_data == '[]'
              field.serial_data = [{"value":"Certified Organic"},{"value":"Organic"},{"value":"Conventional"},{"value":"Other"}].to_json
              field.save!
            end
          elsif field.field_id == 16
            if field.serial_data == '[]'
              field.serial_data = [{"value":"None"},{"value":"Well"},{"value":"Pond/lake"},{"value":"Stream/river"},{"value":"Irrigation system"},{"value":"Other"}].to_json
              field.save!
            end
          elsif field.field_id == 20
            if field.serial_data == '[]'
              field.serial_data = [{"value":"Vegetable"},{"value":"Livestock"},{"value":"Grain"},{"value":"Seed"},{"value":"Hay \u0026 Forage"},{"value":"Orchard/Fruit"},{"value":"Mixed"},{"value":"Other"}].to_json
              field.save!
            end
          end
        end
      end
      if location.seeker_listing?
        location.location_fields.each do |field|
          if field.field_id == 49
            if field.serial_data == '[]'
              field.serial_data = [{"value":"Vegetable"},{"value":"Livestock"},{"value":"Grain"},{"value":"Seed"},{"value":"Hay \u0026 Forage"},{"value":"Orchard/Fruit"},{"value":"Mixed"},{"value":"Other"}].to_json
              field.save!
            end
          elsif field.field_id == 50
            if field.serial_data == '[]'
              field.serial_data =  [{"value":"Certified Organic"},{"value":"Organic"},{"value":"Conventional"},{"value":"Other"}].to_json
              field.save!
            end
          elsif field.field_id == 31
            if field.serial_data == '[]'
              field.serial_data = [{"value":"Agriculture-related degree"},{"value":"Farm management (3 years or less)"},{"value":"Farm management (3 years+)"},{"value":"Apprenticeship"},{"value":"General degree"},{"value":"General farming (3 years or less)"},{"value":"General farming (3 years+)"},{"value":"Other experience/agricultural/business training"}].to_json
              field.save!
            end
          end
        end
      end
    end
  end

  def down
  end
end
