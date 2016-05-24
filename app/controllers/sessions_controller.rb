class SessionsController < ApplicationController
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
        render :new
      end
    end

  end
end
