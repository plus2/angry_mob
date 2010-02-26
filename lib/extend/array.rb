class Array
	def extract_options!
		if Hash === last then pop else {} end
	end
	def extract_options
		dup.extract_options!
	end
end
