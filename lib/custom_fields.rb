require 'active_support/concern'
module CustomFields
  extend ActiveSupport::Concern
  class_methods do
    # ------------------------------------------- add_boolean_with_comment_field
    def add_boolean_with_comment_field( field_name )
      @custom_boolean_fields ||= []
      @custom_boolean_fields << field_name
      konst = const_get( field_name.to_s.upcase )
      define_method( field_name ) do
        load_field( konst )
      end
      define_method( "#{field_name}=" ) do |x|
        f = load_field( konst )
        f.write_boolean_with_comment( x )
        f.save unless new_record?
      end
    end
    # ------------------------------------------- add_boolean_with_comment_field
    def add_boolean_field( field_name )
      @boolean_fields ||= []
      @boolean_fields << field_name
      konst = const_get( field_name.to_s.upcase )
      define_method( field_name ) do
        f = load_field( konst )
        f.boolean_value
      end
      define_method( "#{field_name}=" ) do |x|
        f = load_field( konst )
        f.boolean_value = ( x != FalseClass && x == '0' )
        f.save unless new_record?
      end
    end
    def custom_boolean_fields
      @custom_boolean_fields || []
    end
    def custom_number_fields
      @custom_number_fields || []
    end
    def custom_string_fields
      @custom_string_fields || []
    end
    def custom_text_fields
      @custom_text_fields || []
    end

    # --------------------------------------------------------- add_number_field
    def add_number_field( field_name )
      @custom_number_fields ||= []
      @custom_number_fields << field_name
      konst = const_get( field_name.to_s.upcase )
      define_method( field_name ) do
        load_field( konst ).comment
      end
      define_method( "#{field_name}=", ) do |x|
        f = load_field( konst )
        f.comment = x
        f.boolean_value = false
        f.save unless new_record?
      end
    end

    # --------------------------------------------------------- add_string_field
    def add_string_field( field_name )
      @custom_string_fields ||= []
      @custom_string_fields << field_name
      konst = const_get( field_name.to_s.upcase )
      define_method( field_name ) do
        load_field( konst ).comment
      end
      define_method( "#{field_name}=", ) do |x|
        f = load_field( konst )
        f.comment = x
        f.boolean_value = false #todo: make defualt
        f.save unless new_record?
      end
    end

    # --------------------------------------------------------- add_text_field
    def add_text_field( field_name )
      @custom_text_fields ||= []
      @custom_text_fields << field_name
      konst = const_get( field_name.to_s.upcase )
      define_method( field_name ) do
        load_field( konst ).serial_data
      end
      define_method( "#{field_name}=", ) do |x|
        f = load_field( konst )
        f.serial_data = x
        f.boolean_value = false
        f.save unless new_record?
      end
    end

    # --------------------------------------------------------- add_multiselect_field
    def add_multiselect_field( field_name )
      konst = const_get( field_name.to_s.upcase )
      define_method( field_name ) do
        x = load_field( konst ).serial_data
        if x.present?
          JSON.parse( x )
        else
          []
        end
      end
      define_method( "#{field_name}=", ) do |x|
        array = []
        x.values.each do |data|
          if data['value'].present?|| data['comment'].present?
            array << data
          end
        end
        f = load_field(konst )
        f.serial_data = array.to_json
        f.boolean_value = false
        f.save unless new_record?
      end

    end
  end
  ##############################################################################  

  protected

  ##############################################################################  
  
  def load_field( field_id )
    @_custom_fields ||= {}
    @_custom_fields[field_id] ||= location_fields.find_or_initialize_by( field_id: field_id )
  end
end
