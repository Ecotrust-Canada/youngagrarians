class UserMailer < ActionMailer::Base
  default from: CONFIG[:send_from]

  def listing_approved(location)
    @location = location
    mail(to: @location.email, subject: 'Young Agrarians Resource Map - your listing is live!')
  end

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
