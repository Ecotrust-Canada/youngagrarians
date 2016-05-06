#
class LocationsController < ApplicationController
  require 'spreadsheet'
  require 'fileutils'

  @tmp = {}

  def search
    @locations = Location.search params[:term]
    respond_to do |format|
      format.json { render json: @locations }
    end
  end

  # GET /locations
  # GET /locations.json
  def index
    respond_to do |format|
      format.html do
        redirect_to :root unless authenticated?
        @locations = if params[:filtered].present?
                       Location.where(is_approved: 0).order(:name).all
                     else
                       Location.order(:name).all
                     end
      end
      format.json do
        scope = if params[:surrey]
          Location.surrey
        else
          Location
        end
        @locations = scope.approved.currently_shown.includes( category_tags: { nested_category: :parent } ).order( 'id' )
      end
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    @location = Location.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @location }
    end
  end

  # GET /locations/new
  # GET /locations/new.json
  def new
    @location = Location.new
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @location }
    end
  end

  # GET /locations/1/edit
  def edit
    @categories = Category.all
    @locations = nil
    if params.key? :id
      location = Location.find(params[:id])
      @locations = [location]
      @ids = [location.id]
    elsif params.key? :ids
      @ids = params[:ids].split ','
      @locations = Location.find @ids
    end
  end

  # POST /locations
  # POST /locations.json
  def create
    @location = Location.new(params[:location])
    @location.save
    if params[:subcategories]
      params[:subcategories].uniq.each do |subcategory|
        s = Subcategory.where(id: subcategory[:id]).first
        @location.subcategories << s if s
      end
    end
    respond_to do |format|
      if @location.valid?
        format.html { redirect_to @location, notice: 'Location was successfully created.' }
        format.json { render json: @location, status: :created, location: @location }
      else
        format.html { render action: 'new' }
        format.json { render json: @location.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  def update
    @locations = []
    @errors = []
    if params.key? :id
      location = Location.find(params[:id])
      @locations = [location]
      # ACP:  WTFa??
      location_params = params.clone
      [:created_at, :id, :updated_at, :category, :subcategories, :markerVisible,
       :action, :controller, :location].each do |param|
        location_params.delete param
      end
      location.update_attributes location_params
      @errors = location.errors
    elsif params.key? :locations
      params[:locations][:location].each do |data|
        l = Location.find data[0]
        @errors.push(l.errors) unless l.update_attributes(data[1])
        @locations.push l
      end
    end

    respond_to do |format|
      if @errors.empty?
        format.html { redirect_to :locations, notice: 'Locations successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @locations = nil

    if params.key? :id
      location = Location.find params[:id]
      @locations = [location]
    elsif params.key? :ids
      @locations = Location.find params[:ids].split(',')
    end

    @locations.each(&:destroy) unless @locations.empty?

    respond_to do |format|
      format.html { redirect_to locations_url }
      format.json { head :no_content }
    end
  end

end
