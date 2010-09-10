class AngryHash < Hash
  require 'angry_hash/conversion/by_reference'
  require 'angry_hash/conversion/duplicating'
  require 'angry_hash/extension'
  require 'angry_hash/extension_aware'
  require 'angry_hash/merging'
  require 'angry_hash/initialiser'

  # config
  require 'angry_hash/dsl'
  include AngryHash::DSL

  extend AngryHash::Initialiser


  alias_method :regular_writer, :[]=    unless method_defined?(:regular_writer)
  alias_method :regular_reader, :[]     unless method_defined?(:regular_reader)
  alias_method :regular_update, :update unless method_defined?(:regular_update)

  # store value under key, without dup-ing.
  def []=(key, value)
    regular_writer(__convert_key(key), __convert_value_without_dup(value))
  end

  # fetch value stored under key.
  def [](key)
    regular_reader(__convert_key(key))
  end

  # override id to fetch value stored under 'id'.
  def id
    regular_reader('id')
  end

  # store value under key by duping the value.
  def dup_and_store(key,value)
    regular_writer(__convert_key(key), __convert_value(value))
  end

  # Duplicate the AngryHash
  def dup
    self.class[ self ]
  end


  # override normal Hash methods

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

  ## Convert back to a plain hash

  def to_normal_hash(keys=nil)
    __to_hash(self,keys)
  end

  def __to_hash(value,keys,cycle_guard={})
    return cycle_guard[value.hash] if cycle_guard.key?(value.hash)

    case value
    when Hash
      new_hash = cycle_guard[value.hash] = {}

      if keys == :symbols
        # TODO DRY
        value.inject(new_hash) do |hash,(k,v)|
          hash[k.to_sym] = __to_hash(v,keys,cycle_guard)
          hash
        end
      else
        value.inject(new_hash) do |hash,(k,v)|
          hash[k] = __to_hash(v,keys,cycle_guard)
          hash
        end
      end
    when Array
      new_array = cycle_guard[value.hash] = []

      value.each {|v| new_array << __to_hash(v,keys,cycle_guard)}
    else
      value
    end
  end


  # Support dot notation access
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

  # please be Strings
  def __convert_key(key)
    Symbol === key ? key.to_s : key
  end
  def self.__convert_key(key)
    Symbol === key ? key.to_s : key
  end

  include Merging
  include Conversion::Duplicating
  include Conversion::ByReference
  include ExtensionAware
end
