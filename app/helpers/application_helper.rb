module ApplicationHelper
  include AppWarden::Mixins::HelperMethods
  def current_user
    controller.send( :current_user )
  end

  def google_analytics_code
    <<-EOS
    <script>
      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
      })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

      ga('create', 'UA-44608495-1', 'maps.youngagrarians.org');
      ga('send', 'pageview');
    </script>
    EOS
      .html_safe
  end

  # ------------------------------------------------------------------ icon_hash
  def icon_hash
    icons = Dir.glob( Rails.root.join( "app/assets/images/map-icons/small/*" ) )
    icons.each_with_object( {} ) do |x, m|
      x = File.basename( x )
      key= File.basename(x, File.extname(x))
      m[ key ] = image_path("map-icons/small/#{x}" )
    end
  end

  # -------------------------------------------------------------- big_icon_hash
  def big_icon_hash
    icons = Dir.glob( Rails.root.join( "app/assets/images/map-icons/original/*" ) )
    icons.each_with_object( {} ) do |x, m|
      x = File.basename( x )
      key= File.basename(x, File.extname(x))
      m[ key ] = image_path("map-icons/original/#{x}" )
    end
  end
end
