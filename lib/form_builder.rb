class FormBuilder < ActionView::Helpers::FormBuilder
  attr_accessor :template


  # ------------------------------------------------------------------------ url
  def url( *args )
    text_field( *args )
  end
  # -------------------------------------------------------------- check_box_tag
  def check_box_tag( f, v, cur_val )
    field_name = if f.to_s.match( /\[\]$/ )
      format( '%s[%s][]', object_name, f.to_s.sub(/\?$/, '' )[0..-3] )
    else
      format( '%s[%s]', object_name, f.to_s.sub(/\?$/,"" ) )
    end
    is_checked = cur_val == v
    v = '1' if v.is_a?( TrueClass )
    v = '0' if v.is_a?( FalseClass )
    template.check_box_tag( field_name, v, is_checked )
  end

  # ------------------------------------------------------------- honeypot_field
  def honeypot_field( field, args = {} )
    x = template.text_field( object_name, field )
    label = format_label( field.to_s.humanize )
    klasses = ['form-element', "hp-#{field.to_s.gsub( / /, '_')}"]
    klasses << 'required' if args[:required]
    template.content_tag( 'div', template.content_tag( 'label', label ) + x + append_errors( field ), class: klasses.join(' ' ) )
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
    label = format_label( args[:label] || field.to_s.humanize )
    template.content_tag( 'label', 
                          check_box_tag( field, value, object[field] ) + content_tag( 'span', label ),
                          class: 'check_box')
  end
  # ------------------------------------------------------------ checkbox_option
  def radio_option( field, value, args = {} )
    label = format_label( args[:label] || field.to_s.humanize )
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
    label = format_label( args[:label] || field.to_s.humanize )
    klasses = ['form-element', 'date']
    klasses << 'required' if args[:required]
    template.content_tag( 'div', template.content_tag( 'label', label ) + x + append_errors( field ), class: klasses.join(' ' ) )
  end
  # ---------------------------------------------------------------------- email
  def email( *args )
    text_field( *args )
  end
  # ----------------------------------------------------------------- select_tag
  def select_tag( field, options, args = {} )
    args[:disabled] = true if args[:hidden]
    if object.respond_to?( :errors ) && object.errors[field].any?
      args[:class] = 'field-error'
    end
    field_name = if field.to_s.match( /\[\]$/ )
      format( '%s[%s][]', object_name, field.to_s.sub(/\?$/,"" )[0..-3] )
    else
      format( '%s[%s]', object_name, field.to_s.sub(/\?$/,"" ) )
    end
    x = template.select_tag( field_name, options, args )
    label = format_label( args[:label] || field.to_s.humanize )
    klasses = ['form-element']
    klasses << 'required' if args[:required]
    template.content_tag( 'div',
                          template.content_tag( 'label', label ) + x + append_errors( field ),
                          class: klasses.join( ' ' ),
                          style: args[:hidden] ? 'display:none;' : nil)
  end
  # --------------------------------------------------------------------- select
  def select( field, options, args = {} )
    if object.respond_to?( :errors ) && object.errors[field].any?
      args[:class] = 'field-error'
    end
    x = super( field, options, args, disabled: args[:hidden] )
    label = format_label( args[:label] || field.to_s.humanize )
    klasses = ['form-element']
    klasses << 'required' if args[:required]
    template.content_tag( 'div',
                          template.content_tag( 'label', label ) + x + append_errors( field ),
                          class: klasses.join( ' ' ), 
                          style: args[:hidden] ? 'display:none' : nil)
  end
  [:password_field, :phone_field, :text_field, :email_field, :text_area].each do |field_type|
    class_eval <<-EOC
      def #{field_type}(field, args = {} )
        if object.respond_to?( :errors ) && object.errors[field].any?
          args[:class] = 'field-error'
        end
        x = super
        label = format_label( args[:label] || field.to_s.humanize )
        klasses = ['form-element']
        klasses << 'required' if args[:required]
        template.content_tag( 'div', template.content_tag( 'label', label ) + x + append_errors( field ), class: klasses.join(' ' ) )
      end
    EOC
  end
  # --------------------------------------------------------------------- submit
  def submit( text, args = {} )
    template.content_tag( 'button', text, args.merge( class: 'button-primary' ) )
  end
  # ----------------------------------------------------------- hidden_field_tag
  def hidden_field_tag( *args )
    template.hidden_field_tag( *args )
  end
  # ---------------------------------------------------------------- postal_code
  def postal_code( field, args = {} )
    text_field( field, args.merge( size: 7 ) )
  end
  # --------------------------------------------------------------------- number
  def number( field, args = {} )
    text_field( field, args.merge( size: 10 ) )
  end
  # --------------------------------------------------------------- radio_select
  def radio_select_with_comments( field, choices, options = {} )

    @radio_with_comments_present = true
    label = format_label( options[:label] || field.to_s.humanize )
    val = object.send( field )
    val ||= options[:default] || choices.first if val.nil?
    x = ''.html_safe
    field_name = format( '%s[%s]', object_name, field )
    x = template.safe_join( choices.map do |choice|
                     content_tag( 'label',
                                  template.radio_button_tag( field_name,
                                                             choice,
                                                             val == choice,
                                                             required: options[:required],
                                                             disabled: options[:hidden] ) + choice )
                   end )

    specified  = !choices.include?( val )
    x += content_tag( 'label',
                       template.radio_button_tag( field_name,
                                                  '',
                                                  specified,
                                                  required: options[:required],
                                                  disabled: options[:hidden] ) + 'Specify' )
    x += content_tag( 'span', template.text_field_tag( field_name, specified ? val : '', disabled: !specified ), style: specified ? nil : 'display:none;' )
    klasses = ['form-element', 'radio-with-comments']
    klasses << 'required' if options[:required]
    template.content_tag( 'div',
                          template.content_tag( 'label', label ) + x + append_errors( field ),
                          class: klasses.join(' ' ),
                          style: options[:hidden] ? 'display: none;' : nil )

  end

  # --------------------------------------------------------------- radio_select
  def radio_select( field, choices, options = {} )
    label = format_label( options[:label] || field.to_s.humanize )
    val = object.send( field )
    val = options[:default] || choices.first if val.nil? || !choices.include?( val )
    x = ''.html_safe
    field_name = format( '%s[%s]', object_name, field )
    x = template.safe_join( choices.map do |choice|
                     content_tag( 'label',
                                  template.radio_button_tag( field_name,
                                                             choice,
                                                             val == choice,
                                                             required: options[:required],
                                                             disabled: options[:hidden] ) + choice )
                   end )
    klasses = ['form-element']
    klasses << 'required' if options[:required]
    template.content_tag( 'div',
                          template.content_tag( 'label', label ) + x + append_errors( field ),
                          class: klasses.join(' ' ),
                          style: options[:hidden] ? 'display: none;' : nil )

  end
  # -------------------------------------------------------- boolean_with_number
  def boolean_with_comments( field, args = {} )
    if object.respond_to?( :errors ) && object.errors[field].any?
      args[:class] = 'field-error'
    end
    val = object.send( field )
    label = format_label( args[:label] || field.to_s.humanize )
    b_name = format( '%s[%s][boolean]', object_name, field )
    s_name = format( '%s[%s][string]', object_name, field )
    yes_label = if args[:yes_comments]
                  'Yes (please specify)'
                else
                  'Yes'
                end
    no_label = if args[:no_comments]
                  'No (please specify)'
                else
                  'No'
                end
    x = content_tag( 'label',
                      template.radio_button_tag( b_name,
                                                 args[:no_comments] ? LocationField::NO_WITH_COMMENTS : LocationField::NO,
                                                 ( val.not_set? && args[:default].is_a?(FalseClass ) ) || val.false?,
                                                 class: args[:no_comments] ? 'needs_comments' : nil ) +
                        no_label.html_safe )
    x << content_tag( 'label',
                     template.radio_button_tag( b_name,
                                                args[:yes_comments] ? LocationField::YES_WITH_COMMENTS : LocationField::YES,
                                                ( val.not_set? && args[:default].is_a?( TrueClass ) ) || val.true?,
                                                class: args[:yes_comments] ? 'needs_comments' : nil ) +
                       yes_label.html_safe )
    comments_enabled = if args[:yes_comments] && args[:no_comments]
                         true
                       else
                         val.true? ? args[:yes_comments] : args[:no_comments]
                       end
    x << content_tag( 'span',
                      template.text_field_tag( s_name, val.comment, disabled: !comments_enabled ),
                      class: 'comments',
                      style: comments_enabled ? nil : 'display: none;' )
    klasses = ['form-element']
    klasses << 'required' if args[:required]
    klasses << 'boolean-with-comments'
    @boolean_with_numbers_present = true
    template.content_tag( 'div',
                          template.content_tag( 'label', label ) + x + append_errors( field ), class: klasses.join(' ' ) )
  end
  # -------------------------------------------------------- boolean_with_number
  def boolean_with_number( field, args = {} )
    if object.respond_to?( :errors ) && object.errors[field].any?
      args[:class] = 'field-error'
    end
    val = object.send( field )
    label = format_label( args[:label] || field.to_s.humanize )
    b_name = format( '%s[%s][boolean]', object_name, field )
    s_name = format( '%s[%s][string]', object_name, field )
    no_label = if args[:no_comments]
                  'No (please specify)'
                else
                  'No'
                end
    yes_label = if args[:yes_comments]
                  'Yes (please specify)'
                else
                  'Yes'
                end
    x = content_tag( 'label',
                      template.radio_button_tag( b_name,
                                                 args[:no_comments] ? LocationField::NO_WITH_COMMENTS : LocationField::NO,
                                                 true,
                                                 class: args[:no_comments] ? 'needs_comments' : nil ) +
                        no_label.html_safe )
    x << content_tag( 'label',
                     template.radio_button_tag( b_name,
                                                args[:yes_comments] ? LocationField::YES_WITH_COMMENTS : LocationField::YES,
                                                val.true?,
                                                class: args[:yes_comments] ? 'needs_comments' : nil ) +
                       yes_label.html_safe )
    x << content_tag( 'span',
                      template.text_field_tag( s_name, val.comment ),
                      class: 'comments',
                      style: val.show_comment? ? nil : 'display: none;' )
    klasses = ['form-element']
    klasses << 'required' if args[:required]
    klasses << 'boolean-with-number'
    @boolean_with_numbers_present = true
    template.content_tag( 'div',
                          template.content_tag( 'label', label ) + x + append_errors( field ), class: klasses.join(' ' ) )
  end

  # ----------------------------------------------------------------------- sign
  def sign( field, args = {} )

    x = template.check_box_tag( format( '%s[%s]', object_name, field ),
                                '1',
                                object.send( field ),
                                required: true )
    label = format_label( args[:label] || field.to_s.humanize )
    klasses = ['form-element']
    template.content_tag( 'div', template.content_tag( 'label', ERB::Util.h( label ) + x ), class: klasses.join(' ' ) )
  end
  # ---------------------------------------------------- check_all_with_comments
  def check_all_with_comments( field, choices, args = {} )
    val = object.send( field )
    label = format_label( args[:label] || field.to_s.humanize )
    empty_name = format( '%s[%s][0][value]', object_name, field )
    x = template.hidden_field_tag( empty_name )
    choices.each_with_index do |choice, i|
      v = val.find{ |y| y['value'] == choice }
      b_name = format( '%s[%s][%d][value]', object_name, field, i )
      c_name = format( '%s[%s][%d][comment]', object_name, field, i )
      x << content_tag( 'div', class: 'choice-wrapper' ) do
        content_tag( 'label', template.check_box_tag( b_name, choice, v ) + choice + ' (specify)' ) +
        content_tag( 'span', template.text_field_tag( c_name, v && v.fetch('comment','' ), disabled: !v ),
                      style: v ? nil : 'display: none;',
                      class: 'comments' )
      end
    end
    klasses = ['form-element']
    klasses << 'required' if args[:required]
    klasses << 'check-all-with-comments'
    @check_all_with_comments_present = true
    template.content_tag( 'div',
                          template.content_tag( 'label', label ) + x + append_errors( field ), class: klasses.join(' ' ) )
  end
  # ---------------------------------------------------- check_all_with_comments
  def check_all_with_other( field, choices, args = {} )
    #raise object.send( field ).inspect + field.to_s
    val = object.send( field ).map { |x| x['value'] }
    label = format_label( args[:label] || field.to_s.humanize )
    empty_name = format( '%s[%s][0][value]', object_name, field )
    x = template.hidden_field_tag( empty_name )
    choices.each_with_index do |choice, i|
      v = val.delete( choice )
      b_name = format( '%s[%s][%d][value]', object_name, field, i )
      x << content_tag( 'div', class: 'multiple-choice' ) do
        content_tag( 'label', template.check_box_tag( b_name, choice, v ) + choice )
      end
    end
    x << content_tag( 'div', class: 'choice-wrapper' ) do
        name = format( '%s[%s][%d][value]', object_name, field, choices.length )
        content_tag( 'label', template.check_box_tag( '', nil, val.any? ) + 'Other (specify)' ) +
        content_tag( 'span', template.text_field_tag( name, val.join(','), disabled: val.empty? ),
                      style: val.any? ? nil : 'display: none;',
                      class: 'comments' )
    end
    klasses = ['form-element']
    klasses << 'required' if args[:required]
    klasses << 'check-all-with-comments'
    @check_all_with_comments_present = true
    template.content_tag( 'div',
                          template.content_tag( 'label', label ) + x + append_errors( field ), class: klasses.join(' ' ) )
  end

  # -------------------------------------------------------------------- form_js
  def form_js
    r_val = ''.html_safe
    if has_boolean_with_numbers?
      r_val << <<-EOC
        function onCommentyFieldChange( e )
        {
          var outer = $( e.currentTarget ).closest('.boolean-with-number, .boolean-with-comments')
          var checkedBox = outer.find( ':checked' );
          if( checkedBox.hasClass( 'needs_comments' ) )
          {
            outer.find( 'span.comments' ).show().find( 'input' ).removeProp( 'disabled' );
          }
          else
          {
            outer.find( 'span.comments ').hide().find( 'input' ).prop( 'disabled', true );
          }
        }
        $('div.boolean-with-number, div.boolean-with-comments').on( 'change', 'input[type=radio]', onCommentyFieldChange );
      EOC
      .html_safe
    end
    if @radio_with_comments_present
      r_val << <<-EOC
        function onRadioCommentChange( e )
        {
          var outer = $( e.currentTarget ).closest('.radio-with-comments');
          var el = outer.find( ':checked' );
          if( el.val() == '' )
          {
            outer.find( 'span' ).show().find( 'input' ).removeProp( 'disabled' );
          }
          else
          {
            outer.find( 'span' ).hide().find( 'input' ).prop( 'disabled', 'disabled' );
          }
        }
        $('div.radio-with-comments').on( 'change', 'input[type=radio]', onRadioCommentChange );
      EOC
      .html_safe
      
    end
    if @check_all_with_comments_present 
      r_val << <<-EOC
        function onChoiceWrapperChange( e )
        {
          var outer = $( e.currentTarget ).closest('.choice-wrapper');
          var isChecked = outer.find( ':checked' ).length > 0;
          if( isChecked )
          {
            outer.find( 'span.comments' ).show().find( 'input' ).removeProp( 'disabled' );
          }
          else
          {
            outer.find( 'span.comments ').hide().find( 'input' ).prop( 'disabled', true );
          }
        }
        $('div.choice-wrapper').on( 'change', 'input[type=checkbox]', onChoiceWrapperChange );
      EOC
      .html_safe
    end
    unless r_val.blank?
      r_val = content_tag( 'script', r_val, type: 'text/javascript' )
    end
    return r_val
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
  def content_tag( *args, &b)
    template.content_tag( *args, &b)
  end

  # -------------------------------------------------- has_boolean_with_numbers?
  def has_boolean_with_numbers?
    @boolean_with_numbers_present
  end

  def format_label( l )
    return l if l[-1] == ':' || l[-1] == '?' || l[-1] == '.'
    ERB::Util.h( l ) + ':'.html_safe
  end
end
