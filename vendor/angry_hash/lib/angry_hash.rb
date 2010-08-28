
class AngryHash < Hash
  # config
  require 'angry_hash/dsl'
  include AngryHash::DSL

  def self.[](other=nil)
    if other
      super(__convert(other))
    else
      new
    end
  end

  alias_method :regular_writer, :[]=    unless method_defined?(:regular_writer)
  alias_method :regular_reader, :[]     unless method_defined?(:regular_reader)
  alias_method :regular_update, :update unless method_defined?(:regular_update)

  def []=(key, value)
    regular_writer(__convert_key(key), self.class.__convert_value_without_dup(value))
  end

  def [](key)
    regular_reader(__convert_key(key))
  end

  def id
    regular_reader('id')
  end

  def dup_and_store(key,value)
    regular_writer(__convert_key(key), self.class.__convert_value(value))
  end

  alias_method :regular_merge, :merge unless method_defined?(:regular_merge)
  def merge(hash)
    regular_merge(self.class.__convert_without_dup(hash))
  end

  def merge!(other_hash)
    other_hash.each_pair { |key, value| dup_and_store(key,value) }
    self
  end
  alias_method :update, :merge!

  def dup
    self.class[ self ]
  end

  def deep_merge(other_hash)
    other_hash = AngryHash[other_hash]

    self.regular_merge( other_hash ) do |key, oldval, newval|
      oldval = AngryHash.__convert_value(oldval)
      newval = AngryHash.__convert_value(newval)

      AngryHash === oldval && AngryHash === newval ? oldval.deep_merge(newval) : newval
    end
  end

  def deep_merge!(other_hash)
    replace(deep_merge(other_hash))
    self
  end
  alias_method :deep_update, :deep_merge!

  def reverse_deep_merge(other_hash)
    self.class.__convert_value(other_hash).deep_merge(self)
  end

  def reverse_deep_merge!(other_hash)
    replace(reverse_deep_merge(other_hash))
    self
  end
  alias_method :reverse_deep_update, :reverse_deep_merge!



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


  def method_missing(method,*args,&blk)
    method_s = method.to_s

    key = method_s[0..-2]

    case method_s[-1]
    when ?=
      return super unless args.size == 1 && !block_given?
      self[ key ] = args.first

    when ??
      return super unless args.empty? && !block_given?
      !! self[key]

    when ?!
      return super unless args.empty?
      self[key] = AngryHash.new unless self.key?(key)
      self[key]

    else
      return super unless args.empty? && !block_given?
      self[method_s]
    end
  end

  def __convert_key(key)
    Symbol === key ? key.to_s : key
  end
  def self.__convert_key(key)
    Symbol === key ? key.to_s : key
  end


  # non-duplicating convert
  def self.__convert_without_dup(hash)
    hash.inject(AngryHash.new) do |newhash,(k,v)|
      newhash[__convert_key(k)] = __convert_value_without_dup(v)
      newhash
    end
  end

  def self.__convert_value_without_dup(v)
    v = v.to_hash if v.respond_to?(:to_hash)

    case v
    when AngryHash
      v
    when Hash
      __convert_without_dup(v)
    when Array
      v.map {|vv| __convert_value_without_dup(vv)}
    else
      v
    end
  end


  # duplicating convert
  def self.__convert(hash,cycle_watch=[])
    new_hash = hash.inject(AngryHash.new) do |hash,(k,v)|
      hash.regular_writer( __convert_key(k), __convert_value(v,cycle_watch) )
      hash
    end

    new_hash
  end

  def self.__convert_value(v,cycle_watch=[])
    id = v.__id__

    return if cycle_watch.include? id

    begin
      cycle_watch << id

      original_v = v
      v = v.to_hash if v.respond_to?(:to_hash)

      case v
      when Hash
        __convert(v,cycle_watch)
      when Array
        v.map {|vv| __convert_value(vv,cycle_watch)}
      when Fixnum,Symbol,NilClass,TrueClass,FalseClass,Float,Bignum
        v
      else
        v.dup
      end
    ensure
      cycle_watch.pop
    end
  end
  
end


