class Hash
	def delete_all_of(*keys)
		keys = keys.map {|k| [ k.to_s, k.to_sym ]}.flatten.uniq
		values = values_at(*keys).flatten.compact.uniq
		keys.each {|k| delete k}
		values
	end

  # from ActiveSupport:
  #
  # Returns a new hash with +self+ and +other_hash+ merged recursively.
  def deep_merge(other_hash)
    self.merge(other_hash) do |key, oldval, newval|
      oldval = oldval.to_hash if oldval.respond_to?(:to_hash)
      newval = newval.to_hash if newval.respond_to?(:to_hash)
      oldval.class.to_s == 'Hash' && newval.class.to_s == 'Hash' ? oldval.deep_merge(newval) : newval
    end
  end

  # Returns a new hash with +self+ and +other_hash+ merged recursively.
  # Modifies the receiver in place.
  def deep_merge!(other_hash)
    replace(deep_merge(other_hash))
  end

  # Return a new hash with all keys converted to symbols.
    def symbolize_keys
      inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = value
        options
      end
    end

    # Destructively convert all keys to symbols.
    def symbolize_keys!
      self.replace(self.symbolize_keys)
    end

    def deep_symbolize_keys
      inject({}) do |options, (key, value)|
        options[(key.to_sym rescue key) || key] = __recurse_deep_symbolize_keys(value)
      options
      end
    end

    def __recurse_deep_symbolize_keys(value)
      case value
      when Hash
        value.deep_symbolize_keys
      when Array
        value.map {|v| __recurse_deep_symbolize_keys(v)}
      else
        value
      end
    end
    

end

class AngryHash
    def delete_all_of(*keys)
      keys.map {|k| delete(k.to_s)}.compact.uniq
    end

    require 'angry_hash/merge_string'
    include AngryHash::MergeString
end
