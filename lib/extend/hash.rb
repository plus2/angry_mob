class Hash
	def delete_all_of(*keys)
		keys = keys.map {|k| [ k.to_s, k.to_sym ]}.flatten.uniq
		values = values_at(*keys).flatten.compact.uniq
		keys.each {|k| delete k}
		values
	end
end
