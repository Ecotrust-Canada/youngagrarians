# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # ----------------------------------------------------------- listing_approved
  def listing_approved
    UserMailer.listing_approved( Location.first )
  end
  # ---------------------------------------------------------------- new_listing
  def new_listing
    UserMailer.new_listing( Location.order( 'random()' ).first )
  end

  # ---------------------------------------------------------------- new_listing
  def password_reset
    UserMailer.password_reset( Account.first )
  end
  # ---------------------------------------------------------------- new_listing
  def new_message
    message = Message.new( name: 'Message SEnder', email: 'sender@gmail.com', subject: 'I like bacon', message: 'lorum ipsom' )
    message.entity = Location.find( 45971 )
    UserMailer.deliver_message( message )
  end

end
