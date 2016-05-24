module MessagesHelper
  def cancel_path
    if @location
      location_path( @location )
    else
      account_path( @account )
    end
  end
end
