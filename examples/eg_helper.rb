require 'pathname'
root = Pathname('../..').expand_path(__FILE__)
require 'pp'

UseGem = false

if UseGem
  require 'rubygems'
  require 'angry_hash'
else
  $:.unshift root+'lib'
  require root+'lib/angry_hash'
end

require 'rubygems'
require 'exemplor'

class Object
  def tapp(tag=nil)
    print "#{tag}=" if tag
    pp self
    self
  end
end
