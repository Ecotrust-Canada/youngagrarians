require 'development_mail_interceptor'

# UNCOMMENT FOR DEBUGGING
# ActionMailer::Base.delivery_method = :smtp
# ActionMailer::Base.perform_deliveries = true
# ActionMailer::Base.raise_delivery_errors = true

ActionMailer::Base.smtp_settings = {
  :address              => CONFIG[:smtp_host],
  :port                 => CONFIG[:smtp_port],
  :domain               => CONFIG[:mailer_host],
  :user_name            => CONFIG[:smtp_username],
  :password             => CONFIG[:smtp_password],
  :authentication       => "plain",
  :enable_starttls_auto => true
}

ActionMailer::Base.default_url_options[:host] = CONFIG[:mailer_host]
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?