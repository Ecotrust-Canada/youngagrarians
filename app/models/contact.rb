class Contact
  attr_accessor :email, :subject, :resource_id

  include ActiveModel

  # ------------------------------------------------------------- resource_type=
  def resource_type=( x )
    case x
    when 'user'
      @resource_class = User
    when 'location'
      @resource_class = Location
    else
      raise "Invalid resource type: #{x}"
    end
  end
end
