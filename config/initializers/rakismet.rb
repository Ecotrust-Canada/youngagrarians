  if Rails.env.development?
    Youngagrarians::Application.config.rakismet.key = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
    Youngagrarians::Application.config.rakismet.url = 'localhost'
  else
    token_file = Rails.root.join( 'config/secrets/akismet_key' )
    unless File.exist?( token_file )
      raise "Put a token in #{token_file}"
    end
    key = File.read( token_file )
    Youngagrarians::Application.config.rakismet.key = key
    Youngagrarians::Application.config.rakismet.url = 'http://maps.youngagrarians.org/'
  end
