class AngryMob

  class AngryHash < Hash
    #def initialize(*args)
    #  super(*args) { |h,k| h[k] = AngryHash.new }
    #end

    def self.[](other)
      super(__convert(other))
    end

    alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
    alias_method :regular_reader, :[] unless method_defined?(:regular_reader)
    alias_method :regular_update, :update unless method_defined?(:regular_update)

    def []=(key, value)
      regular_writer(__convert_key(key), AngryHash.__convert_value(value))
    end
    def [](key)
      regular_reader(__convert_key(key))
    end

    def update(other_hash)
      other_hash.each_pair { |key, value| self[key] = value }
      self
    end
    alias_method :merge!, :update

    def deep_merge(other_hash)
      self.merge(other_hash) do |key, oldval, newval|
        oldval = AngryHash.__convert_value(oldval)
        newval = AngryHash.__convert_value(newval)

        AngryHash === oldval && AngryHash === newval ? oldval.deep_merge(newval) : newval
      end
    end

    def deep_merge!(other_hash)
      replace(deep_merge(other_hash))
    end

    def reverse_deep_merge!(other_hash)
      replace(self.class.__convert_value(other_hash).deep_merge(self))
    end




    def key?(key)
      super(__convert_key(key))
    end

    alias_method :include?, :key?
    alias_method :has_key?, :key?
    alias_method :member?, :key?

    def fetch(key, *extras)
      super(__convert_key(key), *extras)
    end
    def values_at(*indices)
      indices.collect {|key| self[__convert_key(key)]}
    end

    def delete(key)
      super __convert_key(key)
    end    

    def to_hash
      self
    end

    def to_normal_hash
      __to_hash(self)
    end
    def __to_hash(value,cycle_guard={})
      return cycle_guard[value.hash] if cycle_guard.key?(value.hash)

      case value
      when Hash
        new_hash = cycle_guard[value.hash] = {}

        value.inject(new_hash) do |hash,(k,v)|
          hash[k] = __to_hash(v,cycle_guard)
          hash
        end
      when Array
        new_array = cycle_guard[value.hash] = []

        value.each {|v| new_array << __to_hash(v,cycle_guard)}
      else
        value
      end

    end

		def merge_string(string)
			match,key,op,value = *string.match(/^([\w\.]+)(\+?=)(.*)$/)

			segments = key.split('.')

			last_segment = segments[-1]
			parent = fetch_path(segments[0..-2])

			unless AngryHash === parent
				raise "parent path element (at #{segments[0..-2] * '.'}) must be an AngryHash, not #{parent.class}"
			end

			target = parent[last_segment]

			case target
			when Array
				__merge_with_op(target,op, [value].flatten.compact)
			when Hash
				raise "not implemented"
			when String
				__merge_with_op(target,op,value.to_s)
			when NilClass
				parent[last_segment] = value
			else
			end
		end

		def __merge_with_op(target,op,value)
			case op
			when '='
				target.replace(value)
			when '+='
				target.replace( target + value )
			end
		end

		def fetch_path(segments)
			segments = segments.dup
			return self if segments.empty?
			ctx = self


			location = []
			while segment = segments.shift
				unless AngryHash === ctx
					raise "Path element at #{location * '.'} is #{ctx.class}, not an AngryHash. Can't descend to #{path}"
				end

				location << segment
				ctx = ctx[segment] ||= AngryHash.new
			end

			ctx
		end

    def method_missing(method,*args,&blk)
      method_s = method.to_s

      key = method_s[0..-2]

      case method_s[-1]
      when ?=
        self[ key ] = args.first

      when ??
        !! self[key]

      when ?!
        self[key] ||= AngryHash.new

      else
        self[method_s]
      end
    end

    def __convert_key(key)
      Symbol === key ? key.to_s : key
    end
    def self.__convert_key(key)
      Symbol === key ? key.to_s : key
    end

    def self.__convert(hash)
      hash.inject(AngryHash.new) do |hash,(k,v)|
        hash[__convert_key(k)] = __convert_value(v)
        hash
      end
    end

    def self.__convert_value(v)
      v = v.to_hash if v.respond_to?(:to_hash)

      case v
      when AngryHash
        v
      when Hash
        __convert(v)
      when Array
        v.map {|v| Hash === v ? __convert_value(v) : v}
      else
        v
      end
    end
    
  end
end
