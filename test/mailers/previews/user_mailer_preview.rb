# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  # ----------------------------------------------------------- listing_approved
  def listing_approved
    UserMailer.listing_approved( Location.first )
  end
  def new_listing
    UserMailer.new_listing( Location.order( 'random()' ).first )
  end

end
