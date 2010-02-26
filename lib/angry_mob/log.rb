class AngryMob
	module Log

		def log(*msg)
			puts "  %-20s| #{msg * ' '}" % self.class.to_s
		end

		def debug(*msg)
			puts "* %-20s| #{msg * ' '}" % self.class.to_s
		end
	end
end
