class AngryMob

  class AutovivifyingHash < Hash
    def initialize(*args)
      super(*args) { |h,k| h[k] = AutovivifyingHash.new }
    end

    def self.[](other)
      super(__convert(other))
    end

    alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
    alias_method :regular_update, :update unless method_defined?(:regular_update)

    def []=(key, value)
      regular_writer(key.to_s, AutovivifyingHash.__convert_value(value))
    end

    def update(other_hash)
      other_hash.each_pair { |key, value| self[key] = value }
      self
    end
    alias_method :merge!, :update

    def deep_merge(other_hash)
      self.merge(other_hash) do |key, oldval, newval|
        oldval = AutovivifyingHash.__convert_value(oldval)
        newval = AutovivifyingHash.__convert_value(newval)

        AutovivifyingHash === oldval && AutovivifyingHash === newval ? oldval.deep_merge(newval) : newval
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

      puts "mm method=#{method} keys=#{keys.inspect}"

      if keys.include? method_s
        fetch(method_s)
      elsif method_s[-1] == ?=
        self[ method_s[0..-2] ] = args.first
      else
        super
      end
    end

    def __convert_key(key)
      Symbol === key ? key.to_s : key
    end
    def self.__convert_key(key)
      Symbol === key ? key.to_s : key
    end

    def self.__convert(hash)
      hash.inject(AutovivifyingHash.new) do |hash,(k,v)|
        hash[__convert_key(k)] = __convert_value(v)
        hash
      end
    end

    def self.__convert_value(v)
      v = v.to_hash if v.respond_to?(:to_hash)

      case v
      when AutovivifyingHash
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

  class AngryStructProxy < BlankSlate
    reveal :extend

    def initialize root, path
      @root,@path = root,path
    end

    def method_missing(method,*args,&blk)
      @root.__called(@path, method, args, &blk)
    end

    def __value
      @root.__fetch(@path)
    end

    def parent
      @root.__get_parent(@path)
    end
  end

  class AngryStruct < AngryStructProxy
    Debug = false

    # main dispatch point. Internal method missing dispatches here.
    def __called(path,method,args,&blk)
      Debug && puts( "\noriginal path=#{path.inspect} method=#{method} args=#{args.inspect[0..100]}" )
      Debug && caller[0..5].tapp

      if method == :[]
        method = args.shift.to_sym
      end
      if method == :[]=
        method = :"#{args.shift}="
      end


      # pre-emptively return a PORO if possible
      if __valid_key?(method)
        target = __fetch(path + [method])
        unless Hash === target || NilClass === target
          return target
        end
      end


      if method == :nil?
        target = __fetch(path)
        NilClass === target || target.empty?
      end

      # handle each & other iterators:
      # XXX need to work out how to delegate Enumerable :P
      if method == :each
        return __each(path,&blk)
      end
      if method == :map
        return __map(path,&blk)
      end
      if method == :keys
        return __keys(path)
      end
      if method == :values
        return __values(path)
      end

      # setter, getter, interrogative
      method_s = method.to_s
      if method_s != '==' && method_s[-1] == ?=
				__set(path,method_s[0..-2].to_sym, args.first)
			else
        __get(path,method,args,&blk)
			end
    end



    # get

    def __get(path,method,args=[],&blk)
      target = __fetch(path)

      puts "getting path=#{path.inspect} method=#{method} args=#{args.inspect}"
      caller[1..5].tapp

      if target.respond_to?(method)
        target.__send__ method, *args, &blk
      else
        __validate_key(path,method)
        __proxy(path + [method])
      end
    end


    # set
    
    def __set(path,key,value)
      Debug && begin
        puts "set"
        self.tapp(:self)
        path.tapp(:path)
        key.tapp(:key)
        puts "value: pclass=#{value.class} value=#{value.inspect[0..100]}"
      end

      __validate_key(path,key)

      target = __fetch(path,true)
      target[key.to_sym] = value
      value
    end

    def __fetch(path,autovivify=false)
      return @hash if path.empty?

      path = path.dup
      ctx  = @hash

      Debug && puts( "__fetch [] #{ctx.inspect[0..100]} #{ctx.class}" )

      if autovivify
        parent_ctx = @hash

        while segment = path.shift
          ctx = ctx[segment]
          Debug && puts( "__fetch [#{segment}] #{ctx.inspect[0..100]} #{ctx.class}" )


          ctx = parent_ctx[segment] = AutovivifyingHash.new
          return ctx unless AutovivifyingHash === ctx

          parent_ctx = ctx
        end
      else
        while segment = path.shift
          if ctx && ctx.key?(segment)
            ctx = ctx[segment]
          else
            ctx = nil
            break
          end
        end
      end

      ctx
    end

    def __key?(target,path,method)
      case target
      when Hash,AutovivifyingHash
        target.key?(method)
      when nil
        false
      else
        target.send(:"#{method}?")
      end
    end

    ValidKeyRe = %r[^[A-Za-z0-9_-]+$]
    # catches a lot of errors
    def __validate_key(path,key)
      key.to_s[ValidKeyRe] || raise("Key '#{key}' isn't suitable for path #{path.inspect}. This is probably an error or not-yet-implemented feature within AngryStruct")
    end
    def __valid_key?(key)
      key.to_s[ValidKeyRe]
    end


    def __get_parent(path)
      path = path.dup
      path.pop
      method = path.pop
      __get(path,method)
    end


    def __each(path,&blk)
      __keys(path).each {|key| yield [key, __get(path,key)] }
    end
    def __map(path,&blk)
      __keys(path).map {|key| yield [key, __get(path,key)] }
    end
    def __keys(path)
      target = __fetch(path)
      if NilClass === target
        []
      else
        target.keys
      end
    end
    def __values(path)
      __map(path) {|(key,value)| value}
    end



    def __proxy(path)
      @proxies ||= {}

      Debug && puts( "AVH: building new proxy #{path.inspect}" )
      proxy = @proxies[path] || AngryStructProxy.new(self,path)

      Debug && puts("selecting powers")
      __select_powers(path).each {|mod| proxy.extend mod}

      proxy
    end

    def __select_powers(path)
      return [] if angry_powers.empty?

      #puts("selecting for path=#{path.inspect}")

      angry_powers.select {|(pattern,_)|
        next if pattern.size != path.size

        #puts("pattern=#{pattern.inspect}")

        (0..pattern.size-1).to_a.all? {|i|
          (pattern[i].nil? || pattern[i] == path[i])
        }#.tapp('matched')
      }.map {|(_,modules)| modules}.flatten.compact

    end


    # public api
    def self.[](original)
      new(original)
    end

    def initialize(original={})
      Debug && begin
        puts("creating new root AngryStruct")
        caller[1..5].tapp
      end
      @hash = AutovivifyingHash[original]
      super(self,[])
    end

    def angry_powers
      @angry_powers ||= []
    end
    def angry_powers=(powers)
      @angry_powers = powers
    end

  end
end
