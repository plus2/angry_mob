require 'pp'

class Object
  def tapp(tag=nil)
    print "#{tag} " if tag
    pp self
    self
	end

	def returning(obj)
		yield obj
		obj
	end
end
