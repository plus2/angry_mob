class Array
	def extract_options!
		if Hash === last then pop else {} end
	end
end
