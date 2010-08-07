class AngryHash
	module ExtensionTracking
		def self.included(base)
			# base.extend ClassMethods
		end
	end

	def extend(mod)
		puts "extending AH #{__id__} with #{mod}"
		super
	end
end
