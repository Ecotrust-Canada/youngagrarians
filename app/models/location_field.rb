class LocationField < ActiveRecord::Base
  YES = 1
  NO = 2
  YES_WITH_COMMENTS = 3
  NO_WITH_COMMENTS = 4
  # -------------------------------------------------------------- show_comment?
  def show_comment?
    boolean_value && ( boolean_value == YES_WITH_COMMENTS || boolean_value == NO_WITH_COMMENTS )
  end

  # ------------------------------------------------------------------- not_set?
  def not_set?
    boolean_value.nil?
  end

  # -------------------------------------------------------------- show_comment?
  def true?
    boolean_value && ( boolean_value == YES_WITH_COMMENTS || boolean_value == YES )
  end

  # -------------------------------------------------------------- show_comment?
  def false?
    boolean_value.nil? || boolean_value == NO_WITH_COMMENTS || boolean_value == NO
  end

  # ------------------------------------------------- write_boolean_with_comment
  def write_boolean_with_comment( x )
    v = x && x['boolean']
    unless v == nil
      v=v.to_i
    end
    unless [nil, YES, NO, YES_WITH_COMMENTS, NO_WITH_COMMENTS].include?( v )
      raise ArgumentError, "Invalid value: #{x} -- #{v}"
    end
    self.boolean_value = v.nil? ? false : v
    self.comment = ( x || {} ).fetch( 'string', nil )
  end
end
