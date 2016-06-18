class CommentsController < ApplicationController
  # --------------------------------------------------------------------- create
  def create
    @location = Location.find( params[:location_id] )
    @comment = @location.comments.new( params.require( :listing_comment ).permit( :body, :name, :email ) )
    @comment.save
    redirect_to location_url( @location )
  end

  # -------------------------------------------------------------------- destroy
  def destroy
    @location = Location.find( params[:location_id] )
    @comment = @location.comments.find( params[:id] )
    if current_user && @location.is_admin?( current_user )
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
