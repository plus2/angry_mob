class Array
	def extract_options!
		if Hash === last then pop else {} end
	end
	def extract_options
		if Hash === last then last else {} end
	end

  def options
    if Hash === last
      self[-1] = AngryMob::AngryHash.__convert(last)
    else
      opts = AngryMob::AngryHash.new
      push opts
      opts
    end
  end
end
