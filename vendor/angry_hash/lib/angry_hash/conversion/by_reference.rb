class AngryHash
  module Conversion
    module ByReference

      # non-duplicating convert
      def __convert_without_dup(hash)
        hash.inject(AngryHash.new) do |newhash,(k,v)|
          newhash[__convert_key(k)] = __convert_value_without_dup(v)
          newhash
        end
      end

      def __convert_value_without_dup(v)
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
      
    end
  end
end
