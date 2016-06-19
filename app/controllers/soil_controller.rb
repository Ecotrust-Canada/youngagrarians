
class SoilController < ApplicationController
  require 'fileutils'
  
  respond_to :json, :html

  def index
    respond_to do |format|
      format.json { render json: [] }
    end  	
  end
end
