class AngryHash
  module Parsing
    module DotNotation
      def add_dotted(dotted)
        dotted.each do |key,value|
          set_dotted(key.to_s,value)
        end
      end

      def set_dotted(key, value)
        parts = key.split(".")
        last = parts.pop

        parent = __resolve_dotted(self, parts)
        parent[last] = value
      end

      def __resolve_dotted(parent, dotted)
        return parent if dotted.empty?

        dotted = dotted.dup
        first = dotted.shift.tapp
        new_child = parent.send("#{first}!")
        __resolve_dotted(new_child, dotted)
      end
    end
  end
end
