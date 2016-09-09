class UpdateSearchColumns < ActiveRecord::Migration
  def up
    if postgres?
      #execute( "DROP TRIGGER tsvectorupdate ON locations")
      execute( "CREATE TRIGGER tsvectorupdate_english
                BEFORE INSERT OR UPDATE
                ON locations
                FOR EACH ROW
                EXECUTE PROCEDURE
                  tsvector_update_trigger(search, 'pg_catalog.english', name, content, description, resource_type, street_address, bioregion)" )

      execute( "CREATE TRIGGER tsvectorupdate_french
                BEFORE INSERT OR UPDATE
                ON locations
                FOR EACH ROW
                EXECUTE PROCEDURE
                  tsvector_update_trigger(search, 'pg_catalog.french', name, content, description, street_address, bioregion)" )

      execute( "UPDATE locations SET search =
                  to_tsvector( 'english', COALESCE( name, '' ) ) ||
                  to_tsvector( 'english', COALESCE( content, '' ) ) || 
                  to_tsvector( 'english', COALESCE( description, '' ) ) ||
                  to_tsvector( 'english', COALESCE( resource_type, '' ) ) ||
                  to_tsvector( 'english', COALESCE( street_address, '' ) ) ||
                  to_tsvector( 'english', COALESCE( bioregion, '' ) ) ||
                  to_tsvector( 'french', COALESCE( name, '' ) ) ||
                  to_tsvector( 'french', COALESCE( content, '' ) ) || 
                  to_tsvector( 'french', COALESCE( description, '' ) ) ||
                  to_tsvector( 'french', COALESCE( street_address, '' ) ) ||
                  to_tsvector( 'french', COALESCE( bioregion, '' ) )" ) 
    end
  end
  # ------------------------------------------------------------------ postgres?
  def postgres?
    ActiveRecord::Base.connection.instance_of?( ActiveRecord::ConnectionAdapters::PostgreSQLAdapter  )
  rescue NameError
    return false
  end

  def down
    execute( "DROP TRIGGER IF EXISTS tsvectorupdate ON locations")
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
