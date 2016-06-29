class SessionsController < ApplicationController
  layout 'basic'
  # ------------------------------------------------------------------------ new
  def new
    redirect_to locations_url if current_user
  end
  # --------------------------------------------------------------------- create
  def create
    account = Account.find_by( email: params[:session] && params[:session][:email] )
    if account && account = account.authenticate( params[:session][:password] )
      session['account_id'] = account.id
      if params[:for_listing]
        in_progress_location.merge!( 'account_id' => account.id )
        session[:in_progress_location] = ActiveSupport::Gzip.compress( in_progress_location.to_json )
        redirect_to new_listing_url
      else
        redirect_to locations_url
      end
    else
      flash[:error] = 'Could not log in; please check your email or password.'
      if params[:for_listing]
        @skeleton = true
        @location = Location.new( in_progress_location )
        render 'locations/account_setup', layout: 'basic'
      else
        render :new
      end
    end
  end

  def destroy
    session.delete( 'account_id' )
    redirect_to login_url
  end
end
