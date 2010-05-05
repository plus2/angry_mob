class AngryMob
  class Util
    class << self
      def snake_case(str)
        return str.downcase if str =~ /^[A-Z_]+$/
        str.gsub(/\B[A-Z]/, '_\&').squeeze('_') =~ /_*(.*)/
        return $+.downcase
      end
    end
  end
end
