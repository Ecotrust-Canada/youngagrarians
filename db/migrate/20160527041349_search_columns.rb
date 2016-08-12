class SearchColumns < ActiveRecord::Migration
  def change
    if postgres?
      execute( "ALTER TABLE locations ADD search tsvector" )
      execute( "CREATE TRIGGER tsvectorupdate
                BEFORE INSERT OR UPDATE
                ON locations
                FOR EACH ROW
                EXECUTE PROCEDURE
                  tsvector_update_trigger(search, 'pg_catalog.english', name, content, description, resource_type)" )
      execute( "UPDATE locations SET search =
                  to_tsvector( 'english',COALESCE( name, '' ) ) ||
                  to_tsvector( 'english', COALESCE( content, '' ) ) || 
                  to_tsvector( 'english', COALESCE( description, '' ) ) ||
                  to_tsvector( 'english', COALESCE( resource_type, '' ) )" ) 
    end
  end
  # ------------------------------------------------------------------ postgres?
  def postgres?
    ActiveRecord::Base.connection.instance_of?( ActiveRecord::ConnectionAdapters::PostgreSQLAdapter  )
  rescue NameError
    return false
  end

end
