require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'

#
module RailsAdminUnapproveResource
end

module RailsAdmin
  module Config
    module Actions
      #
      class UnapproveResource < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :link_icon do
          'icon-uncheck'
        end

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

        register_instance_option :controller do
          proc do
            @locations = Location.find params[:bulk_ids]
            @locations.each do |l|
              l.is_approved = false
              l.save
            end

            flash[:notice] = "You have unapproved #{@locations.size} locations"

            redirect_to back_or_index
          end
        end
      end
    end
  end
end
