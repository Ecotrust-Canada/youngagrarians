class FormBuilder < ActionView::Helpers::FormBuilder
  attr_accessor :template
  def phone_number( *args )
    text_field( *args )
  end
  def url( *args )
    text_field( *args )
  end
  # -------------------------------------------------------------- check_box_tag
  def check_box_tag( f, v, cur_val )
    field_name = if f.to_s.match( /\[\]$/ )
      format( '%s[%s][]', object_name, f.to_s.sub(/\?$/,"" )[0..-3] )
    else
      format( '%s[%s]', object_name, f.to_s.sub(/\?$/,"" ) )
    end
    is_checked = cur_val == v
    v = '1' if v.is_a?( TrueClass )
    v = '0' if v.is_a?( FalseClass )
    template.check_box_tag( field_name, v, is_checked )
  end
  # -------------------------------------------------------------- check_box_tag
  def radio_button_tag( f, v, cur_val )
    field_name = if f.to_s.match( /\[\]$/ )
      format( '%s[%s][]', object_name, f.to_s.sub(/\?$/,"" )[0..-3] )
    else
      format( '%s[%s]', object_name, f.to_s.sub(/\?$/,"" ) )
    end
    is_checked = cur_val == v
    v = '1' if v.is_a?( TrueClass )
    if v.is_a?( FalseClass )
      v = '0' 
      is_checked = true if cur_val.nil?
    end
    template.radio_button_tag( field_name, v, is_checked )
  end
  # ------------------------------------------------------------ checkbox_option
  def checkbox_option( field, value, args = {} )
    label = args[:label] || field.to_s.humanize
    template.content_tag( 'label', 
                          check_box_tag( field, value, object[field] ) + content_tag( 'span', label ),
                          class: 'check_box')
  end
  # ------------------------------------------------------------ checkbox_option
  def radio_option( field, value, args = {} )
    label = args[:label] || field.to_s.humanize
    template.content_tag( 'label', 
                          radio_button_tag( field, value, object[field] ) + content_tag( 'span', label ),
                          class: 'radio')
  end
  # ----------------------------------------------------------------------- date
  def date( field, args = {} )
    if object.respond_to?( :errors ) && object.errors[field].any?
      args[:class] = 'field-error'
    end
    x = date_field( field, args )
    label = args[:label] || field.to_s.humanize
    klasses = ['form-element', 'date']
    klasses << 'required' if args[:required]
    template.content_tag( 'div', template.content_tag( 'label', label ) + x + append_errors( field ), class: klasses.join(' ' ) )
  end
  # ---------------------------------------------------------------------- email
  def email( *args )
    text_field( *args )
  end
  def select_tag( field, options, args = {} )
    if object.respond_to?( :errors ) && object.errors[field].any?
      args[:class] = 'field-error'
    end
    field_name = if field.to_s.match( /\[\]$/ )
      format( '%s[%s][]', object_name, field.to_s.sub(/\?$/,"" )[0..-3] )
    else
      format( '%s[%s]', object_name, field.to_s.sub(/\?$/,"" ) )
    end
    x = template.select_tag( field_name, options, args )
    label = args[:label] || field.to_s.humanize
    klasses = ['form-element']
    klasses << 'required' if args[:required]
    template.content_tag( 'div',
                          template.content_tag( 'label', label ) + x + append_errors( field ),
                          class: klasses.join( ' ' ) )
  end
  # --------------------------------------------------------------------- select
  def select( field, options, args = {} )
    if object.respond_to?( :errors ) && object.errors[field].any?
      args[:class] = 'field-error'
    end
    x = super
    label = args[:label] || field.to_s.humanize
    klasses = ['form-element']
    klasses << 'required' if args[:required]
    template.content_tag( 'div',
                          template.content_tag( 'label', label ) + x + append_errors( field ),
                          class: klasses.join( ' ' ) )
  end
  [:password_field, :text_field, :email_field, :text_area].each do |field_type|
    class_eval <<-EOC
      def #{field_type}(field, args = {} )
        if object.respond_to?( :errors ) && object.errors[field].any?
          args[:class] = 'field-error'
        end
        x = super
        label = args[:label] || field.to_s.humanize
        klasses = ['form-element']
        klasses << 'required' if args[:required]
        template.content_tag( 'div', template.content_tag( 'label', label ) + x + append_errors( field ), class: klasses.join(' ' ) )
      end
    EOC
  end
  # --------------------------------------------------------------------- submit
  def submit( text, args = {} )
    template.content_tag( 'button', text, class: 'button-primary' )
  end
  # ----------------------------------------------------------- hidden_field_tag
  def hidden_field_tag( *args )
    template.hidden_field_tag( *args )
  end
  ##############################################################################

  protected

  ##############################################################################
  def append_errors( field )
    if object.respond_to?( :errors ) && object.errors[field].any?
      template.content_tag( 'ul', class: 'error_list' ) do
        template.safe_join( object.errors[field].map{ |x| template.content_tag( 'li', x ) }, '' )
      end
    else
      ''.html_safe
    end
  end
  # ---------------------------------------------------------------- content_tag
  def content_tag( *args )
    template.content_tag( *args)
  end
end
