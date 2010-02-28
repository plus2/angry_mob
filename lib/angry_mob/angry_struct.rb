class AngryMob

  class AVHash < Hash
    def initialize(*args)
      super(*args) { |h,k| h[k] = AVHash.new }
    end

    def self.[](other)
      super(__convert(other))
    end

    alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
    alias_method :regular_update, :update unless method_defined?(:regular_update)

    def []=(key, value)
      regular_writer(key.to_sym, AVHash.__convert_value(value))
    end

    def update(other_hash)
      other_hash.each_pair { |key, value| self[key] = value }
      self
    end
    alias_method :merge!, :update

    def deep_merge(other_hash)
      self.merge(other_hash) do |key, oldval, newval|
        oldval = AVHash.__convert_value(oldval)
        newval = AVHash.__convert_value(newval)

        AVHash === oldval && AVHash === newval ? oldval.deep_merge(newval) : newval
      end
    end

    def deep_merge!(other_hash)
      replace(deep_merge(other_hash))
    end

    def reverse_deep_merge!(other_hash)
      replace(self.class.__convert_value(other_hash).deep_merge(self))
    end


    def key?(key)
      super(key.to_sym)
    end

    alias_method :include?, :key?
    alias_method :has_key?, :key?
    alias_method :member?, :key?

    def fetch(key, *extras)
      super(key.to_sym, *extras)
    end
    def values_at(*indices)
      indices.collect {|key| self[key.to_sym]}
    end

    def delete(key)
      super key.to_sym
    end    

    def to_hash
      self
    end

    def self.__convert(hash)
      hash.inject(AVHash.new) do |hash,(k,v)|
        hash[k.to_sym] = __convert_value(v)
        hash
      end
    end

    def self.__convert_value(v)
      v = v.to_hash if v.respond_to?(:to_hash)

      case v
      when AVHash
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
  end

  class AngryStruct < AVHash
    Debug = true

    def __called(path,method,args,&blk)
      Debug && puts( "\noriginal path=#{path.inspect} method=#{method} args=#{args.inspect[0..100]}" )
      Debug && caller[0..5].tapp

      # handle each & other iterators:
      if method == :each
        return __each(path,&blk)
      end
      if method == :map
        return __map(path,&blk)
      end

      method_s = method.to_s
			if method_s != '==' && method_s[-1] == ?=
				__set(path,method_s[0..-2].to_sym, args.first)
			else
        __get(path,method,args,&blk)
			end
    end

    def __get(path,method,args,&blk)
      # TODO handle method = [] key = args.first

      parent = __fetch(path)

      Debug && puts( "__get parent=#{parent.inspect[0..100]} class=#{parent.class}" )
      Debug && puts( "      path=#{path.inspect} method=#{method}" )
      Debug && caller[1..3].tapp

      case parent
      when Hash,AVHash,nil
        if parent.respond_to?(method)
          Debug && puts( "AVH: sending method #{method}(args=#{args.inspect[0..100]}) to path=#{path.inspect}" )
          parent.send method, *args, &blk
        else
          __proxy(path + [method])
        end
      else
        Debug && puts( "Obj: sending method #{method}(args=#{args.inspect[0..100]}) to path=#{path.inspect}" )
        parent.send(method,*args,&blk)
      end
    end

    def __set(path,key,value)
      Debug && begin
        puts "set"
        self.tapp(:self)
        path.tapp(:path)
        key.tapp(:key)
        puts "value: pclass=#{value.class} value=#{value.inspect[0..100]}"
      end

      __fetch(path)[key.to_sym] = value
      value
    end

    def __fetch(path)
      return self if path.empty?

      path = path.dup
      ctx  = self
      parent_ctx = self
      Debug && puts( "__fetch [] #{ctx.inspect[0..100]} #{ctx.class}" )

      while segment = path.shift
        ctx = ctx[segment]
        Debug && puts( "__fetch [#{segment}] #{ctx.inspect[0..100]} #{ctx.class}" )

        ctx = parent_ctx[segment] = AVHash.new if NilClass === ctx
        return ctx unless AVHash === ctx

        parent_ctx = ctx
      end

      ctx
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

      angry_powers.select {|(pattern,_)|
        puts "matching? pattern=#{pattern.inspect} path=#{path.inspect}"
        next if pattern.size != path.size

        puts "matching pattern=#{pattern.inspect} path=#{path.inspect}"

        (0..pattern.size-1).to_a.all? {|i|
          (pattern[i].nil? || pattern[i] == path[i])
        }.tapp('matched?')
      }.map {|(_,modules)| modules}.flatten.compact

    end

    def __each(path,*args,&blk)
      __keys(path).each {|key| yield [key, __get(path,key,args)] }
    end
    def __map(path,*args,&blk)
      __keys(path).map {|key| yield [key, __get(path,key,args)] }
    end
    def __keys(path)
      __get(path,:keys,[])
    end

    # public api

    def each(&blk)
      __each([],&blk)
    end
    def map(&blk)
      __map([],*blk)
    end

    def angry_powers
      @angry_powers ||= []
    end
    def angry_powers=(powers)
      @angry_powers = powers
    end

    def each(&blk)
      # TODO - ensure each yielded value is proxied
      super {|value| }
    end

    def method_missing(method,*args,&blk)
      __called([], method, args, &blk)
		end

  end
end
