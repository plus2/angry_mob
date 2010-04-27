class Array
	def extract_options!
		if Hash === last then pop else {} end
	end
	def extract_options
		if Hash === last then last else {} end
	end

  def options
    if Hash === last
      self[-1] = AngryHash.__convert(last)
    else
      opts = AngryHash.new
      push opts
      opts
    end
  end

  def norm
    n = flatten
    n.compact!
    n
  end

  def norm!
    flatten!
    compact!
    self
  end
end
