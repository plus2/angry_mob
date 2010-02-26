class AngryMob
	class SubAngryStruct < BlankSlate
		reveal :extend

		def initialize(root,parent,key,table)
			@root = root
			@parent = parent
			@key = key

			# root
			if table.nil? && NilClass === parent && key.nil?
				table = {}
			end

			__set_table(table)

			unless NilClass === parent
				@path = [ parent.__path, key ].flatten.compact
			else
				@path = []
			end


			@root.__instil_special_powers(self)
		end


		# api
		def to_hash
			@table.dup if !@table.nil?
		end

		def nil?
			@table.nil?
		end

		def key?(k)
			if ! @table.nil?
				@table.key?(k.to_sym)
			end
		end

		def keys
			if @table.nil?
				[]
			else
				@table.keys
			end
		end

		def reverse_deep_update!
			raise NotImplemented
		end
		def delete_all_of
			raise NotImplemented
		end
		def update
			raise NotImplemented
		end

		# implementation
		def __path; @path end

		def __set(key,value)
			key = key.to_sym

			if @table.nil?
				__set_nil(key,value)
			else
				__set_value(key,value)
			end
		end
		alias_method :[]=, :__set

		def __set_value(key,value)
			@table[key.to_sym] = value
			__return_value(key,value)
		end

		def __return_value(key,value)
			case value
			when Hash
				__child(key, value)
			else
				value
			end
		end

		def __child(key,value)
			@children ||= {}

			if child = @children[key]
				child.__set_table(value)
			else
				@children[key] = SubAngryStruct.new(@root,self, key,value)
			end

			@children[key]
		end

		def __set_table(table)
			@table = table

			if !@table.nil?
				@table.each_key {|k| 
					if String === k
						@table[k.to_sym] = @table.delete(k)
					end
				}
			end
		end

		def __set_nil(key,value)
			@table = @parent.__autovivify(self,@key)
			__set(key,value)
		end

		def __get(key)
			key = key.to_sym

			if @table.nil?
				return __child(key,nil)
			end

			value = @table[key]

			case value
			when Hash,nil
				__child(key,value)
			else
				value
			end
		end

		alias_method :[], :__get

		def __autovivify(child,key)
			if @table.nil?
				@table = @parent.__autovivify(self,@key)
			end

			@table[key] = {}
		end

		def method_missing(method,*args,&blk)
			puts "mm: #{method}"
			#caller[1..6].tapp

			# TODO handle ?

			method_s = method.to_s
			if method_s[-1] == ?=
				__set(method_s[0..-2].to_sym, args.first)
			else
				__get(method)
			end
		end
	end

	class AngryStruct < SubAngryStruct
		def initialize *args

			if args.size == 1
				table = args.first
			else
				table,@options = args.first, args.last
			end

			table ||= {}
			@options ||= {}

			@powers = @options[:powers] || {}

			super(self,nil,nil,table)
		end

		def __instil_special_powers(struct)

			powers = if Proc === powers
				[ @powers[struct.__path] ]
			else
				[ @powers[struct.__path] ]
			end

			powers.flatten!
			powers.compact!

			powers.each {|p| struct.extend p}
		end
	end
end
