class AccountsController < ApplicationController
  respond_to :html

  # ----------------------------------------------------------------------- show
  def show
    redirect_to locations_url
  end

  # ------------------------------------------------------------------------ new
  def new
    render layout: 'basic'
  end

  # --------------------------------------------------------------------- create
  def create
    @account = Account.new( params.require( :account ).permit( :email, :password, :password_confirmation ) )
    if current_user.nil? && @account.save
      session['account_id'] = @account.id
      if params[:for_listing]
        in_progress_location.merge!( 'account_id' => @account.id )
        session[:in_progress_location] = ActiveSupport::Gzip.compress( in_progress_location.to_json )
        redirect_to new_listing_url
      else
        redirect_to map_url
      end
    else
      if params[:for_listing]
        @location = Location.new( in_progress_location )
        @skeleton = true
        render 'locations/account_setup', layout: 'basic'
      else
        render :new
      end
    end

  end

  # ACCOUNT UPDATING NOT AVAILABLE. SEE UPDATE_PASSWORD BELOW.
  #  def update
  #    @user = current_user
  #
  #    @user.update_attributes(params[:user])
  #
  #    flash[:notice] = I18n.t('accounts.update_successful')
  #    respond_with @user, :location => :account
  #  end

  def update_password
    @user = current_user

    old_password = params[:old_password]
    new_password = params[:new_password]

    if old_password == '' || new_password == ''
      flash[:notice] = I18n.t('accounts.password_blank')
    elsif @user.valid_password?(old_password)
      flash[:notice] = I18n.t('accounts.password_wrong')
    else
      @user.update_attributes(password: new_password)
      flash[:notice] = I18n.t('accounts.password_update_successful')
    end

    respond_with @user, location: :account
  end

  def forgot_password
    @user = User.new

    redirect_to(params[:return_url] || :locations) if authenticated?

    render :forgot_password, layout: 'basic'
  end

  def retrieve_password
    @user = User.where(email: params[:email]).first

    if @user
      Notifications.reset_password(@user).deliver
      render :password_sent, layout: 'basic'
    else
      flash.now[:notice] = t('emails.reset_password.retrieval_failed')
      render :forgot_password, layout: 'basic'
    end
  end

  def password_reset
    @user = User.where(password_reset_key: params[:code]).first

    if @user
      render :password_reset, layout: 'application'
    else
      redirect_to :login, notice: t('passwords.reset_failed')
    end
  end

  def reset_password
    @user = User.where(password_reset_key: params[:code]).first

    if @user
      if @user.reset_password!(params[:user][:password])
        # log them in!
        self.current_user = @user

        redirect_to :locations, notice: t('passwords.updated')
      else
        flash[:notice] = t('passwords.reset_failed')
        render :password_reset, layout: 'application'
      end
    else
      redirect_to :login, notice: t('passwords.reset_failed')
    end
  end

  # ---------------------------------------------------------------------- login
  def login
    if authenticated?
      redirect_to '/admin'
    else
      render :login, layout: 'basic'
    end
  end

  # ----------------------------------------------------------------- login_post
  def login_post
    params[:email] = User.first.email
    u = User.find_by( email: params[:email] )
    if u && u.valid_password?( params[:password] )
      session[:admin_user_id] = u.id
      redirect_to '/admin'
    else
      flash[:error] = "Your email or password was incorrect."
      render 'login', layout: 'basic'
    end
  end

  def logout
    session[:admin_user_id] = nil
    redirect_to :locations, notice: 'You have been logged out successfully'
  end

  def verify_credentials
    authenticate(:user, :basic)

    raise UnauthenticatedError unless current_user

    render json: current_user
  end

  def validate_beta_code(code)
    if code == 'acqurate_secret_account_creation_access'
      return MailingList.new(first_name: '', last_name: '')
    else
      user_id = code[0, 24]
      encoded_email = code[24, 32]

      listee = MailingList.where(id: user_id).first
      if listee && encoded_email == Digest::MD5.hexdigest(listee.email)
        return listee unless listee.deleted
        return false
      end
      return false
    end
  end
end
