class PasswordResetsController < ApplicationController
  layout 'basic'

  # ----------------------------------------------------------------------- show
  def show
    data = JSON.parse( Base64.urlsafe_decode64( params[:id] ) )
    @account = Account.find( data.fetch( 'id' ) )
    expiry = Time.at( data.fetch( 'expiry' )  )
    if expiry > Time.current
      if @account.reset_password_token( expiry ).to_s == params[:id].to_s
        render :show, layout: 'basic'
        return
      end
    end
    render :expired, layout: 'basic'
  end

  # --------------------------------------------------------------------- update
  def update
    data = JSON.parse( Base64.urlsafe_decode64( params[:id] ) )
    @account = Account.find( data.fetch( 'id' ) )
    expiry = Time.at( data.fetch( 'expiry' )  )
    if expiry > Time.current
      if @account.reset_password_token( expiry ).to_s == params[:id].to_s
        @account.update_attributes( params.require( :account ).permit( :password, :password_confirmation ) )
        redirect_to login_url
        return
      end
    end
    render :expired, layout: 'basic'
  end
  # --------------------------------------------------------------------- create
  def create
    
    account = if params[:password_reset]
      Account.find_by( email: params[:password_reset][:email] )
    end
    if account
      UserMailer.password_reset( account ).deliver_now
    end
  end
end
