class ChangeDataTypeForIsApprovedInLocation < ActiveRecord::Migration
  def up
    return unless postgres?

    execute( "ALTER TABLE locations ALTER is_approved DROP DEFAULT" )
    change_column :locations, :is_approved, 'BOOLEAN USING CAST(is_approved AS BOOLEAN)'
    execute( "ALTER TABLE locations ALTER is_approved SET DEFAULT FALSE" )
  end

  def down
    return unless postgres?

    execute( "ALTER TABLE locations ALTER is_approved DROP DEFAULT" )
    change_column :locations, :is_approved, 'INTEGER USING CAST(is_approved AS INTEGER)'
    execute( "ALTER TABLE locations ALTER is_approved SET DEFAULT 0" )
  end
end

def postgres?
  ActiveRecord::Base.connection.instance_of?( ActiveRecord::ConnectionAdapters::PostgreSQLAdapter  )
rescue NameError
  return false
end
