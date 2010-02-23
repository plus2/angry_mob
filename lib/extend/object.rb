require 'pp'

class Object
  def tapp(tag=nil)
    print "#{tag} " if tag
    pp self
    self
  end
end
