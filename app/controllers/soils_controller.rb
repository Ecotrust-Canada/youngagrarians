
class SoilsController < ApplicationController
  require 'fileutils'
  
  respond_to :json

  def show
    respond_to do |format|
      sql = "SELECT ST_AsGeoJSON(geom) FROM soil WHERE ST_Intersects( ST_MakeEnvelope("+params['lon1']+", "+params['lat1']+", "+params['lon2']+", "+params['lat2']+", 4326), soil.geom) LIMIT 40;"
      records_array = ActiveRecord::Base.connection.execute(sql)
      json = []
      records_array.each do |rec|
       #json.push("{\"geo\": "+rec["st_asgeojson"]+", \"eco_id\":"+rec['eco_id']+"}")
       json.push(rec["st_asgeojson"])
      end
      #format.json { render json: records_array}
      format.json { render json: '[' + json.join(',') + ']'}
    end
  end
end
