module Honeypot
  def self.included( klass )
    klass.extend( ClassMethods )
  end
  def check_honeypot
    r_val = true
    self.class.honeypot_fields.each do |field|
      if send( field ).present?
        self.errors.add( :base, 'record is not valid' )
        r_val = false
      end
    end
    return r_val
  end
  module ClassMethods
    def has_honeypot( field )
      @honeypot_fields ||= []
      @honeypot_fields << field
      attr_accessor field
      validate :check_honeypot
    end
    def honeypot_fields
      @honeypot_fields || []
    end
  end
end
