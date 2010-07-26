# from extlib
class Object
  ##
  # Returns true if the object is nil or empty (if applicable)
  #
  #   [].blank?         #=>  true
  #   [1].blank?        #=>  false
  #   [nil].blank?      #=>  false
  #
  # @return [TrueClass, FalseClass]
  #
  # @api public
  def blank?
    nil? || (respond_to?(:empty?) && empty?)
  end
  def present?
    ! blank?
  end
end # class Object

class Numeric
  ##
  # Numerics are never blank
  #
  #   0.blank?          #=>  false
  #   1.blank?          #=>  false
  #   6.54321.blank?    #=>  false
  #
  # @return [FalseClass]
  #
  # @api public
  def blank?
    false
  end
  def present?
    true
  end
end # class Numeric

class NilClass
  ##
  # Nil is always blank
  #
  #   nil.blank?        #=>  true
  #
  # @return [TrueClass]
  #
  # @api public
  def blank?
    true
  end
  def present?
    false
  end
end # class NilClass

class TrueClass
  ##
  # True is never blank.
  #
  #   true.blank?       #=>  false
  #
  # @return [FalseClass]
  #
  # @api public
  def blank?
    false
  end
  def present?
    true
  end
end # class TrueClass

class FalseClass
  ##
  # False is always blank.
  #
  #   false.blank?      #=>  true
  #
  # @return [TrueClass]
  #
  # @api public
  def blank?
    true
  end
  def present?
    false
  end
end # class FalseClass

class String
  ##
  # Strips out whitespace then tests if the string is empty.
  #
  #   "".blank?         #=>  true
  #   "     ".blank?    #=>  true
  #   " hey ho ".blank? #=>  false
  #
  # @return [TrueClass, FalseClass]
  #
  # @api public
  def blank?
    strip.empty?
  end
  def present?
    ! blank?
  end
end # class String
