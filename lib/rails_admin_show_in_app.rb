# HACK: modification for show in app for our Single Page Application... in reality
# we should use a fully RESTFUL appraoch and let backbone router handle all paths other than /admin
module RailsAdmin
  module Config
    module Actions
      class ShowInApp < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :member do
          true
        end

        register_instance_option :visible? do
          authorized? && (bindings[:controller].main_app.url_for(bindings[:object]) rescue false)
        end

        register_instance_option :controller do
          Proc.new do
            resource_name = @object.class.name.downcase.pluralize
            redirect_to main_app.url_for(@object).sub("/#{resource_name}", "/\#/#{resource_name}")
          end
        end

        register_instance_option :link_icon do
          'icon-eye-open'
        end

        register_instance_option :pjax? do
          false
        end
      end
    end
  end
end