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
        if current_user
          @locations = current_user.locations.order(:name)
          render layout: 'basic'
        else
          redirect_to map_url
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
      format.html do
        if @location.visible? || @location.is_admin?( current_user )
          render layout: 'basic'
        else
          render nothing: true, status: 404
        end
      end
      format.json { render json: @location }
    end
  end

  # ------------------------------------------------------------------------ new
  def new
    @location = Location.new
    respond_to do |format|
      format.html do
        render_form
      end
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
    session[:in_progress_location] ||= {}
    session[:in_progress_location].merge!( params.require( :location ).permit( { nested_category_ids: [] }, :name, :description, :street_address, :city, :phone, :fb_url, :twitter_url, :email, :public_contact, :show_until, :account_id, :province, :country ))
    session[:in_progress_location_time] = Time.current.to_i

    @location = Location.new( session[:in_progress_location] )
    if params[:done]
      @location.account_id = nil unless current_user && current_user.id == @location.account_id
      session.delete( :in_progress_location )
      @location.save
    else
      redirect_to new_location_path
      return
    end
    respond_to do |format|
      if @location.valid?
        format.html { redirect_to @location, notice: 'Location was successfully created.' }
        format.json { render json: @location, status: :created, location: @location }
      else
        format.html do
          render_form
          return
        end
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

  ##############################################################################

  protected

  ##############################################################################

  def render_form
    if session[:in_progress_location_time] && Time.at( session[:in_progress_location_time] ) > 20.minutes.ago
      @location = Location.new( session[:in_progress_location] ) if session[:in_progress_location]
    else
      session.delete( :in_progress_location )
      @location = Location.new
    end
    @skeleton = true
    if params[:step]
      case params[:step]
      when 'contact'
        render :contact, layout: 'basic'
      when 'details'
        render :details, layout: 'basic'
      when 'account'
        render :account_setup, layout: 'basic'
      else
        render :new, layout: 'basic'
      end
    else
      if session[:in_progress_location] && session[:in_progress_location]['name']
        render :contact, layout: 'basic'
      elsif session[:in_progress_location] && session[:in_progress_location]['name']
        render :contact, layout: 'basic'
      elsif session[:in_progress_location]  && ( session[:in_progress_location]['account_id']  || session[:in_progress_location]['skip_account'] ) 
        render :details, layout: 'basic'
      elsif session[:in_progress_location]  && session[:in_progress_location]['nested_category_ids'] 
        render :account_setup, layout: 'basic'
      else
        render :new, layout: 'basic'
      end
    end
  end
end
