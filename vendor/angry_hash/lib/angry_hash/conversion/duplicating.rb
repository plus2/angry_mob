class AngryHash
  module Conversion
    module Duplicating
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # duplicating convert
        def __convert(hash,cycle_watch=[])
          new_hash = hash.inject(AngryHash.new) do |hash,(k,v)|
            hash.regular_writer( __convert_key(k), __convert_value(v,cycle_watch) )
            hash
          end

          new_hash
        end

        def __convert_value(v,cycle_watch=[])
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

      def __convert(hash,cycle_watch=[])
        self.class.__convert(hash,cycle_watch)
      end

      def __convert_value(v,cycle_watch=[])
        self.class.__convert_value(v,cycle_watch)
      end

    end
  end
end
