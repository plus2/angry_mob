class AngryHash < Hash
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

  def method_missing(method,*args,&blk)
    method_s = method.to_s

    key = method_s[0..-2]

    case method_s[-1]
    when ?=
      self[ key ] = args.first

    when ??
      !! self[key]

    when ?!
      self[key] = AngryHash.new if !self.key?(key)
      self[key]

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
    when Hash
      __convert(v)
    when Array
      v.map {|v| __convert_value(v)}
    when Fixnum,Symbol,NilClass,TrueClass,FalseClass,Float
      v
    else
      v.dup
    end
  end
  
end


