require 'eg_helper'
require 'angry_mob'


mob = AngryMob::Rioter.new


class DirectoryTarget < AngryMob::Target
  nickname :dir

  default_action
	def create
    definition_file.tapp(:c)
    puts "create #{dir} #{dir.exist?}"
  end


	protected
	def default_object
		@default_object ||= Pathname( args.default_object )
	end
  alias_method :dir, :default_object


  def state
    {
      :exists => dir.exist?
    }
  end
end


class Database
	include AngryMob::Actor

  build do |info|
    case info.tapp(:info)[:kind]
    when 'pg'
      PgDatabase
    end
  end
end


class PgDatabase < Database

  def run!(*args)
    args.tapp "pg_database"

    dir "/tmp/pg"
  end
end


eg 'attrs' do
	attributes = { :fire => %w{thing} }

	mob = AngryMob::Mob.new('/tmp')
	builder = AngryMob::Builder.new(attributes)

	builder.from_block(mob) do 
		act 'thing/thing', :on => 'thing' do
			dir "/tmp/foo.txt"
			dir "/tmp/foo.txt"
			dir "/tmp/foo.txt"

      act_now Database, {:kind => 'pg'}
		end
	end


	rioter = builder.to_rioter
	rioter.riot!('exemplor', attributes)
end
