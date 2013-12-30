class UserMailer < ActionMailer::Base
  default from: CONFIG[:send_from]

  def listing_approved(location)
    @location = location
    mail(:to => @location.email, :subject => "Young Agrarians Resource Map – your listing is live!")
  end
end
