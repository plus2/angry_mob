
class AngryMob
  class Node < Struct.new(:name,:attributes,:resource_locator)
    include Log

    def initialize(name, attributes)
      self.name = name
      self.attributes = AngryHash[attributes]
    end

    def merge_defaults(attrs)
      attributes.reverse_deep_update!(attrs)
    end

    def method_missing(method,*args,&block)
      attributes.__send__(method,*args)
    end
  end
end
