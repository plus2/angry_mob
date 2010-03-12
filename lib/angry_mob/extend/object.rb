require 'pp'

class Object
  def tapp(tag=nil)
    print "#{tag} " if tag
    pp self
    self
	end

	def stapp(tag=nil)
    print "#{tag} " if tag
		puts "c=#{self.class} i=#{self.inspect[0..100]}"
    self
	end


	def returning(obj)
		yield obj
		obj
	end
end
