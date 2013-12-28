class UserMailer < ActionMailer::Base
  default from: CONFIG[:send_from]

  def listing_approved(location)
    @location = location
    mail(:to => @location.email, :subject => "Listing Approved")
  end
end
