class AddProvinceToTsvectorLocation < ActiveRecord::Migration
  def up
    if postgres?
      execute( "DROP TRIGGER update_search_field ON locations")

      execute( "CREATE OR REPLACE FUNCTION tsvector_location_search_field() RETURNS trigger AS $$
                DECLARE
                  tmp_search TEXT;
                  child_search TEXT;
                BEGIN
                  SELECT string_agg(nc.name, ' ') INTO child_search
                  FROM category_location_tags clt
                  INNER JOIN nested_categories nc ON clt.category_id = nc.id
                  WHERE clt.location_id = NEW.id;
                
                  tmp_search := '';
                
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.name, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.content, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.description, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.resource_type, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.street_address, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.bioregion, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.city, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.province, '');
                  tmp_search := tmp_search || ' ' || COALESCE(child_search, '');
                
                  NEW.search := to_tsvector(tmp_search);
                  RETURN NEW;
                END;
                $$ LANGUAGE plpgsql" )


      execute( "CREATE TRIGGER update_search_field
                BEFORE INSERT OR UPDATE
                ON locations
                FOR EACH ROW
                EXECUTE PROCEDURE
                  tsvector_location_search_field()" )

      # The trigger will take care of setting the search field
      execute( "UPDATE locations SET id = id " )
    end
  end

  def down
    if postgres?
      execute( "DROP TRIGGER update_search_field ON locations")

      execute( "CREATE OR REPLACE FUNCTION tsvector_location_search_field() RETURNS trigger AS $$
                DECLARE
                  tmp_search TEXT;
                  child_search TEXT;
                BEGIN
                  SELECT string_agg(nc.name, ' ') INTO child_search
                  FROM category_location_tags clt
                  INNER JOIN nested_categories nc ON clt.category_id = nc.id
                  WHERE clt.location_id = NEW.id;
                
                  tmp_search := '';
                
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.name, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.content, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.description, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.resource_type, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.street_address, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.bioregion, '');
                  tmp_search := tmp_search || ' ' || COALESCE(NEW.city, '');
                  tmp_search := tmp_search || ' ' || COALESCE(child_search, '');
                
                  NEW.search := to_tsvector(tmp_search);
                  RETURN NEW;
                END;
                $$ LANGUAGE plpgsql" )


      execute( "CREATE TRIGGER update_search_field
                BEFORE INSERT OR UPDATE
                ON locations
                FOR EACH ROW
                EXECUTE PROCEDURE
                  tsvector_location_search_field()" )

      # The trigger will take care of setting the search field
      execute( "UPDATE locations SET id = id " )
    end
  end

  # ------------------------------------------------------------------ postgres?
  def postgres?
    ActiveRecord::Base.connection.instance_of?( ActiveRecord::ConnectionAdapters::PostgreSQLAdapter  )
  rescue NameError
    return false
  end

end
