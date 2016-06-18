class UserMailer < ActionMailer::Base
  default from: CONFIG[:send_from]
  layout 'mail'

  # ----------------------------------------------------------- listing_approved
  def listing_approved(location)
    @location = location
    addresses = []
    addresses << @location.email if @location.email.present?
    addresses << @location.account.email if @location.account && @location.account.email
    mail(to: addresses, subject: 'Young Agrarians Resource Map - your listing is live!')
  end

  # ------------------------------------------------------------- password_reset
  def password_reset( user )
    @user = user
    mail(to: user.email, subject: 'Young Agrarians: Password Reset')
  end

  # ----------------------------------------------------------- listing_approved
  def new_listing( location )
    @location = location
    mail(to: 'farm@youngagrarians.org',
          subject: 'Young Agrarians - Listing Needs Approval')
  end

  # ----------------------------------------------------------- listing_approved
  def new_listing_registration( location )
    @location = location
    addresses = []
    addresses << @location.email if @location.email.present?
    addresses << @location.account.email if @location.account && @location.account.email
    mail(to: addresses,
          subject: 'Young Agrarians - New Listing')
  end

  # ------------------------------------------------------------ deliver_message
  def deliver_message( message )
    to = []
    if message.entity.is_a?( Account )
    else
      to << message.entity.email if message.entity.email.present?
      to << message.entity.account.email if message.entity.account
    end
    # TODO: validate email reply to string
    # TODO: Wrap body in nice layout
    mail( to: to, subject: message.subject, reply_to: "#{message.name} <#{message.email}>" ) do |format|
      format.text { render text: message.message }
    end
  end
end
