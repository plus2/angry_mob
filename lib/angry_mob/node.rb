
class AngryMob
  class Node < Struct.new(:name,:attributes,:resource_locator)
    include Log

    def initialize(name, attributes)
      self.name = name
      self.attributes = AngryHash[attributes]
    end

    def merge_defaults!(attrs)
      puts "merging defaults"
      attributes.reverse_deep_merge!(attrs)
    end

    def consolidate!
      node = self
      __consolidate_hash(attributes,{})
    end

    def __consolidate_hash(hash,seen)

      return if seen.key?(hash)
      seen[hash] = true

      hash.each do |key,value|
        case value
        when Hash
          __consolidate_hash(value,seen)
        when Proc
          hash[key] = value[self]
        end
      end
    end

    def method_missing(method,*args,&block)
      attributes.__send__(method,*args)
    end
  end
end
