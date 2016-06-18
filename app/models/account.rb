class Account < ActiveRecord::Base
  has_secure_password
  validates :email, uniqueness: true

  has_many :locations, inverse_of: :account

  # ------------------------------------------------------- reset_password_token
  def reset_password_token( expiry = nil )
    expiry ||= 1.week.since
    data_to_sign = [ updated_at.to_i, expiry.to_i, id, password ].map( &:to_s )
    s = OpenSSL::HMAC.digest( OpenSSL::Digest.new( 'sha1' ),
                              Youngagrarians::Application.config.secret_token,
                              data_to_sign.join( '-' ) )
    s = Base64.encode64( s )

    Base64.urlsafe_encode64( { id: id, expiry: expiry.to_i, signature: s }.to_json ).strip
  end

end
