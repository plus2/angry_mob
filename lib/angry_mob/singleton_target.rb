class AngryMob
  class SingletonTarget < Target
		class << self
			def instance_key(args)
				"singleton:#{nickname}"
			end
		end
  end
end
