class AngryHash
  module MergeString
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
  end
end
