class AngryHash
  module Merging
    def self.included(base)
      base.class_eval do
        alias_method :regular_merge, :merge unless method_defined?(:regular_merge)
      end
    end


    ## Merging

    # Shallow merge hash.
    def merge(hash)
      super(__convert_without_dup(hash))
    end

    # Shallow merge! hash.
    def merge!(other_hash)
      other_hash.each_pair { |key, value| dup_and_store(key,value) }
      self
    end
    alias_method :update, :merge!


    # Merge deeply. The other hash's contents are favoured.
    def deep_merge(other_hash)
      other_hash = AngryHash[other_hash]

      self.regular_merge( other_hash ) do |key, oldval, newval|
        oldval = __convert_value(oldval)
        newval = __convert_value(newval)

        AngryHash === oldval && AngryHash === newval ? oldval.deep_merge(newval) : newval
      end
    end

    # Merge deeply, replacing the AngryHash with the result.
    def deep_merge!(other_hash)
      replace(deep_merge(other_hash))
      self
    end
    alias_method :deep_update, :deep_merge!

    # Merge deeply in reverse. This hash's contents are favoured.
    def reverse_deep_merge(other_hash)
      __convert(other_hash).deep_merge(self)
    end

    # Merge deeply in reverse, replacing this AngryHash with the result. This hash's contents are favoured.
    def reverse_deep_merge!(other_hash)
      replace(reverse_deep_merge(other_hash))
      self
    end
    alias_method :reverse_deep_update, :reverse_deep_merge!
  end
end
