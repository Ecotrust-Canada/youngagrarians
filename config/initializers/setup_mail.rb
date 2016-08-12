
# config/secrets/mail_creds.yml sammple file for sendgrid:
#
# development: &development
#   user_name: 
#   password: 
#   domain: 
#   address: 'smtp.sendgrid.net'
#   port: 587
#   authentication: 'plain'
#   enable_starttls_auto: true
# production:
#   <<: *development
#
if Rails.env.test?
  ActionMailer::Base.default_url_options[:host] = 'test.host'
else
  token_file = Rails.root.join( 'config/secrets/mail_creds.yml' ).to_s
  unless File.exist?( token_file )
    raise "Put mail creds in #{token_file}"
  end
  mail_creds = ( YAML.load_file( token_file ).fetch( Rails.env.to_s ) || {} ).symbolize_keys
  defaults = {
    address: CONFIG[:smtp_host] || '',
    port: CONFIG[:smtp_port] || '',
    domain: CONFIG[:mailer_host] || '',
    user_name: CONFIG[:smtp_username] || '',
    password: CONFIG[:smtp_password] || '',
    authentication: 'plain',
    enable_starttls_auto: true
  }
  ActionMailer::Base.smtp_settings = defaults.merge( mail_creds )

  ActionMailer::Base.default_url_options[:host] = CONFIG[:mailer_host]
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.raise_delivery_errors = true

  if Rails.env.development?
    require 'development_mail_interceptor'
    ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) 
  end

  Premailer::Rails.config.merge!( preserve_styles: true, remove_ids: true,   generate_text_part: true )
end
