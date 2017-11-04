if Rails.env.production?
  Rails.application.config.middleware.use ExceptionNotification::Rack,
    email: {
      email_prefix: "[PREFIX] ",
      sender_address: format( '"%s" <%s>', "YoungAgrarians App", 'no-reply@youngagrarians.org' ),
      exception_recipients: ENV['ERROR_EMAIL'] || "theyoungagrarians@gmail.com"
    }
end
