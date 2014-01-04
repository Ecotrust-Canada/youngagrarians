class AdminController < RailsAdmin::MainController
  def locations_import
    if params.has_key? :dump and params[:dump].has_key? :csv_file
      begin
        Location.import(params[:dump][:csv_file].tempfile)
        redirect_to locations_url, notice: "Successfuly imported all locations! :)"
      rescue => e
        msg = "There appears to be a problem with the import. Details: #{e}"
        puts "Error: #{msg}"
        flash.now[:error] = msg
        render :csv_import
      end
    end
  end
end