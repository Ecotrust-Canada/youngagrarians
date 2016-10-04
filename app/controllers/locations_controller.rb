#
class LocationsController < ApplicationController
  require 'spreadsheet'
  require 'fileutils'

  @tmp = {}
  
  # --------------------------------------------------------------------- cancel
  def cancel
    session.delete( :in_progress_location )
    redirect_to map_url
  end

  def thanks
    render layout: 'basic'
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
          Location.all
        end
        if params[:services_supplies_land]
          scope = scope.services_supplies_land
        end
        scope = apply_distance_sort_scope( scope ) if params[:center_lat] && params[:center_long]
        scope = apply_search_scope( scope ) if params[:q].present?
        scope = scope.order( 'updated_at DESC' ) if params[:recent]
        @locations = scope.approved.currently_shown.includes( :nested_categories ).order( 'id' )
      end
    end
  end

  # GET /locations/1
  # GET /locations/1.json
  def show
    require 'rest-client'
    @location = Location.find(params[:id] )
    
    if @location.is_approved == 0 && ! @location.admin?( current_user ) && !session[:admin_user_id]
      render 'not-approved', layout:'basic', status: 403
    else

      @wp_posts = @location.load_wp_posts()
    
      respond_to do |format|
        format.html do
          if @location.visible? || @location.admin?( current_user )
            if @location.land_listing?
              render 'show_land_listing', layout: 'basic'
            elsif @location.seeker_listing?
              render 'show_seeker', layout: 'basic'
            else
              render layout: 'basic'
            end
          else
            render nothing: true, status: 404
          end
        end
        format.json { render json: @location }
      end
    end
  end

  # ------------------------------------------------------------------------ new
  def new
    render_form
  end

  # GET /locations/1/edit
  def edit
    @location = Location.find( params[:id] )
    unless @location.admin?( current_user )
      redirect_to map_url
    end
    if @location.land_listing?
      render :edit_land_listing, layout: 'basic'
    elsif @location.seeker_listing?
      render :edit_seeker_listing, layout: 'basic'
    else
      render layout: 'basic'
    end
  end

  # POST /locations
  # POST /locations.json
  # --------------------------------------------------------------------- create
  def create
    @location = Location.new( in_progress_location )
    in_progress_location.merge!( location_params )
    session[:in_progress_location_time] = Time.current.to_i
    @location.attributes = in_progress_location
    if params[:done]
      @location.account_id = nil unless current_user && current_user.id == @location.account_id
      if @location.nested_category_ids.empty?
        @location.nested_category_ids = [@location.primary_category_id]
      end

      session.delete( :in_progress_location )
      @location.save
      UserMailer.new_listing( @location ).deliver_now
      if @location.email.present? || @location.account
        UserMailer.new_listing_registration( @location ).deliver_now
      end
    else
      session[:in_progress_location] = ActiveSupport::Gzip.compress( in_progress_location.to_json )
      redirect_to new_location_url( step: params[:step] )
      return
    end
    respond_to do |format|
      if @location.valid?
        format.html { redirect_to thanks_url, notice: 'Location was successfully created.' }
      else
        format.html do
          render_form
          return
        end
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.json
  # --------------------------------------------------------------------- update
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
    if @location.admin?( current_user )
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

  # ---------------------------------------------------------------- render_form
  def render_form
    if session[:in_progress_location_time] && Time.at( session[:in_progress_location_time] ) > 20.minutes.ago
      begin
        @location ||= begin
          loc = if session[:in_progress_location]
            JSON.parse( ActiveSupport::Gzip.decompress( session[:in_progress_location] ) )
          else
            {}
          end
          Location.new( loc )
        end
        
      rescue ActiveRecord::UnknownAttributeError 
        session.delete( :in_progress_location )
        @location = Location.new
      end
    else
      session.delete( :in_progress_location )
      session.delete( :in_progress_location_time )
      @location = Location.new
    end
    unless @location.primary_category_id
      render :new, layout: 'basic'
      return
    end
    @skeleton = true
    if params[:step]
      case params[:step]
      when 'contact'
        render :contact, layout: 'basic'
      when 'description'
        render_description_form
      when 'account'
        render :account_setup, layout: 'basic'
      when 'categories'
        render :new, layout: 'basic'
      else
        raise "Unknown step: #{params[:step]}"
        render :new, layout: 'basic'
      end
    else
      if @location.name.present? || @location.details_complete
        render :contact, layout: 'basic'
      elsif @location.account_id.present? || session[:in_progress_location]['skip_account']
        render_description_form
      elsif @location.primary_category_id
        render :account_setup, layout: 'basic'
      else
        render :new, layout: 'basic'
      end
    end
  end
  # ------------------------------------------------------------ location_params
  def location_params
    args = [{ nested_category_ids: [] },
              :primary_category_id,
              :name,
              :description,
              :bioregion,
              :postal,
              :street_address,
              :city,
              :url,
              :phone,
              :fb_url,
              :twitter_url,
              :email,
              :postal,
              :public_contact,
              :show_until,
              :account_id,
              :province,
              :country,
              :details_complete ]
    if params[:signature]
      e = Time.at( params[:expiry].to_i )
      s, _ = @location.signature( e )
      if e > Time.current && s == params[:signature]
        args << :is_approved
      else
        args = []
      end
    end
    if @location && @location.land_listing?
      args += Location.land_params
    elsif @location && @location.seeker_listing?
      args += Location.seeker_params
    end
    params.require( :location ).permit( *args )
  end

  # --------------------------------------------------------- apply_search_scope
  def apply_search_scope( scope )
    query = ActiveRecord::Base.send(:sanitize_sql_like, params[:q])
    category_scope = NestedCategory.joins( 'JOIN category_location_tags ON category_location_tags.category_id = nested_categories.id' )
		                   .where( 'name LIKE ?', "%#{query}%" )
    location_ids = category_scope.pluck( 'category_location_tags.location_id' )
    # for speed of getting this done, and avoid the table sequential scans expected by throwing an OR statement in here,
    # i've implemented the category name check as a separate query. 
    if ActiveRecord::Base.connection.instance_of?( ActiveRecord::ConnectionAdapters::PostgreSQLAdapter  )
      args = []
      tokens = generate_tokens(query)
      clause = tokens.map.with_index do |phrase, i|
        args << phrase
        'to_tsquery(?)'
      end.join( ' && ' )

      if location_ids.any?
        args << location_ids
        scope.where( "search @@ (#{clause}) OR locations.id IN ( ? )", *args )
      else
        if args.include? "ON" # ON is a reserved stop word in pg fulltext search apparently! Let's have a special case:
          args << "Ontario"
          scope.where( "locations.province = 'ON' OR search @@ (#{clause})", *args)
        else
          scope.where( "search @@ (#{clause})", *args )
        end
      end
    else
      if location_ids.any?
        scope.where( 'description LIKE ? OR id IN ?', "%#{query}%", location_ids )
      else
        scope.where( 'description LIKE ?', "%#{query}%" )
      end
    end
  end

  # -------------------------------------------------- generate_tokens
  def generate_tokens(query)
    #query = query.gsub(/Ontario/i, 'ON')
    query = query.gsub(/Quebec/i, 'QC')
    query = query.gsub(/Nova Scotia/i, 'NS')
    query = query.gsub(/New Brunswick/i, 'NB')
    query = query.gsub(/Manitoba/i, 'MB')
    query = query.gsub(/British Columbia/i, 'BC')
    query = query.gsub(/Prince Edward Island/i, 'PE')
    query = query.gsub(/Saskatchewan/i, 'SK')
    query = query.gsub(/Alberta/i, 'AB')
    query = query.gsub(/Newfoundland and Labrador/i, 'NL')

    return query.split( /\s+/ )
  end

  # -------------------------------------------------- apply_distance_sort_scope
  def apply_distance_sort_scope( scope )
    lat = params[:center_lat].to_f 
    long = params[:center_long].to_f 
    scope.order( "SQRT( POW( latitude-#{lat}, 2 ) + POW( longitude - #{long}, 2 )  )" )
  end

  # ---------------------------------------------------- render_description_form
  def render_description_form
    if @location.land_listing?
      render :new_land_listing, layout: 'basic'
    elsif @location.seeker_listing?
      render :new_seeker_listing, layout: 'basic'
    else
      render :details, layout: 'basic'
    end
  end
  
end
