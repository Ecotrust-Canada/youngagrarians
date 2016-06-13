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
        session[:in_progress_location] ||= {}
        session[:in_progress_location]['account_id'] = account.id
        redirect_to new_listing_url
      else
        redirect_to locations_url
      end
    else
      if params[:for_listing]
        @skeleton = true
        render 'locations/account_setup', layout: 'basic'
      else
        flash[:error] = 'Please check email or password.'
        render :new
      end
    end

  end
  def destroy
    session.delete( 'account_id' )
    redirect_to login_url
  end
end
