require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
 
module RailsAdminApproveResource
end
 
module RailsAdmin
  module Config
    module Actions
      class ApproveResource < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :link_icon do
          'icon-check'
        end

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

        register_instance_option :controller do
          Proc.new do
            @locations = Location.find params[:bulk_ids]
            @locations.each do |l|
              l.is_approved = true
              l.save
            end

            flash[:notice] = "You have approved #{@locations.size} locations"

            redirect_to back_or_index
          end
        end
      end
    end
  end
end