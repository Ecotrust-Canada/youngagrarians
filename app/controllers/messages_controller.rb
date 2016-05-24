class MessagesController < ApplicationController
  before_filter :load_entity
  
  def new
    @message = Message.new
    render layout: 'basic'
  end

  def create
    @message = Message.new( params.require( :message ).permit( :name, :email, :link, :message, :subject ).to_hash )
    @message.entity = @location || @user
    if @message.valid?
      UserMailer.deliver_message( @message ).deliver_now
      redirect_to @location ? location_url( @location ) : user_url( @user )
    else
      render :new, layout: 'basic'
    end
  end

  ##############################################################################

  protected

  ##############################################################################
  def load_entity
    @location = Location.find( params[:location_id] ) if params[:location_id]
    @user = User.find( params[:user_id] ) if params[:user_id]
    redirect_to map_url if @user.nil? && @location.nil?
  end
end

