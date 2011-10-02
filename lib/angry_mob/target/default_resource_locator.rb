class AngryMob
  class Target
    class DefaultResourceLocator
      def resource(target, name)
        path = target.definition_file.to_s.sub(/\.([^\.]+)$/,'')
        (path.pathname + name.to_s)
      end
      alias_method :[], :resource
    end
  end
end
