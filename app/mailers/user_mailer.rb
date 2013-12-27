class UserMailer < ActionMailer::Base
  default from: "admin@youngagrarians.org"

  def listing_approved(location)
    @location = location
    mail(:to => @location.email, :subject => "Listing Approved")
  end
end
