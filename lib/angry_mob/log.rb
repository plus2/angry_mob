class AngryMob
	module Log

		def __class_to_s
			@__class_to_s ||= __class_to_s!
		end
		def __class_to_s!
			@__class_to_s = self.class.to_s.sub(/^AngryMob::/,'AM::').sub(/^Target\[/,'T[')
			@__class_to_s[0..19]
		end

		def log(*msg)
			puts "  %-20s| #{msg * ' '}" % __class_to_s
		rescue
			puts "#{self.class.to_s} | #{msg * ' '}"
		end

		def debug(*msg)
			puts "* %-20s| #{msg * ' '}" % __class_to_s
		rescue
			puts "Debug #{self.class.to_s} | #{msg * ' '}"
		end
	end
end
