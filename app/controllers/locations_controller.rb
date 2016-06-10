#
class LocationsController < ApplicationController
  require 'spreadsheet'
  require 'fileutils'

  @tmp = {}

  def search
    @locations = Location.search params[:term]
    @locations = []
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

        scope = apply_search_scope( scope ) if params[:q].present?
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
    @location = Location.find( params[:id] )
    unless @location.admin?( current_user )
      redirect_to map_url
    end
    render layout: 'basic'
  end

  # POST /locations
  # POST /locations.json
  def create
    session[:in_progress_location] ||= {}
    session[:in_progress_location].merge!( location_params )
    session[:in_progress_location_time] = Time.current.to_i

    @location = Location.new( session[:in_progress_location] )
    if params[:done]
      @location.account_id = nil unless current_user && current_user.id == @location.account_id
      session.delete( :in_progress_location )
      @location.save
      UserMailer.new_listing( @location ).deliver_now
      UserMailer.new_listing_registration( @location ).deliver_now
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
    @location = Location.find(params[:id])
    if @location.admin?( current_user ) || params[:signature]
      @location.update_attributes location_params
    end

    respond_to do |format|
      if @location.valid?
        format.html { redirect_to location_url( @location ) }
      else
        format.html { render action: 'edit' }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.json
  def destroy
    @location = Location.find( params[:id] )
    if @location.is_admin?( current_user )
      @location.destroy
    else
      redirect_to map_url
    end

    respond_to do |format|
      format.html { redirect_to locations_url }
      format.json { render text: @location }
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
  # ------------------------------------------------------------ location_params
  def location_params
    args = [{ nested_category_ids: [] }, :name, :description, :street_address, :city, :phone, :fb_url, :twitter_url, :email, :public_contact, :show_until, :account_id, :province, :country]
    if params[:signature]
      e = Time.at( params[:expiry].to_i )
      s, _ = @location.signature( e )
      if e > Time.current && s == params[:signature]
        args << :is_approved
      else
        args = []
      end
    end
    params.require( :location ).permit( *args )
  end

  # --------------------------------------------------------- apply_search_scope
  def apply_search_scope( scope )
    if ActiveRecord::Base.connection.instance_of?( ActiveRecord::ConnectionAdapters::PostgreSQLAdapter  )
      args = []
      clause = params[:q].split( /\s+/ ).map do |phrase|
        args << phrase
        'to_tsquery(?)'
      end.join( ' && ' )
      scope.where( "search @@ (#{clause})", *args )
    else
      scope.where( 'description LIKE ?', "%#{params[:q]}%" )
    end
  end
end
