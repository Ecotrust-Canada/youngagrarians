class CommentsController < ApplicationController
  # --------------------------------------------------------------------- create
  def create
    @location = Location.find( params[:location_id] )
    @comment = @location.comments.new( params.require( :listing_comment ).permit( :body, :name, :email ) )
    # Check the comment using rakismet gem
    @comment.is_spam = @comment.spam?
    Rails.logger.info "+ Adding comment with akismet reponse: #{@comment.akismet_response}"
    @comment.save

    # Return early if the comment is a spam comment, as we don't want to notify either admin or the registered user about it
    return redirect_to location_url( @location ) if @comment.is_spam

    if @location.email.present? || @location.account
      UserMailer.new_comment( @comment ).deliver_now
    end

    UserMailer.new_comment_for_admin( @comment ).deliver_now

    redirect_to location_url( @location )
  end

  # -------------------------------------------------------------------- destroy
  def destroy
    @location = Location.find( params[:location_id] )
    @comment = @location.comments.find( params[:id] )
    if @location.is_admin?( current_user ) || current_admin_user
      @comment.destroy
      respond_to do |format|
        format.html{ redirect_to location_url( @location ) }
        format.json{ render json: @comment }
      end
    else
      respond_to do |format|
        format.html do
          flash[:error] = "You are not allowed to remove that comment."
          redirect_to location_url( @location )
        end
        format.json do
          render json: @comment, status: 403
        end
      end
    end
  end
end
