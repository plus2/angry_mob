require 'eg_helper'
require 'angry_mob'


mob = AngryMob::Rioter.new


class DirectoryTarget < AngryMob::Target
  nickname :dir


  default_action
	def create
    puts "create #{default_object} #{exist?}"
  end


	protected
	def default_object
		@default_object ||= Pathname( args.default_object )
	end


  def state
    {
      :exists => exist?
    }
  end
end


class Database
	include AngryMob::Actor
end


eg 'attrs' do
	attributes = { :fire => %w{thing} }

	mob = AngryMob::Mob.new('/tmp')
	builder = AngryMob::Builder.new(attributes)

	builder.from_block(mob) do 
		act 'thing/thing', :on => 'thing' do
			dir "/tmp/foo.txt"
		end
	end


	rioter = builder.to_rioter
	rioter.riot!('exemplor', attributes)
end
