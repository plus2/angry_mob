require 'angry_mob'

#mob = AngryMob::Builder.new do
#end.to_mob

mob = AngryMob::Rioter.new

class ServiceTarget < AngryMob::SingletonTarget
  nickname :service
  known_actions :start, :stop, :enable, :disable
end

class Apache2Target < ServiceTarget
  nickname :apache2

  def state
    {
      :etc => '/etc/apache2'.pathname.exist?
    }
  end

  action :enable do
    puts "enable apache powers!"
  end

  action :start do
    puts "start apachin"
  end

  action :restart do
    puts "restarting apache"
  end
end

class DirectoryTarget < AngryMob::Target
  nickname :dir

  def state
    {
      :exists => exist?
    }
  end

  default_action :create do
    puts "create #{default_object} #{exist?}"
  end
end

mob.add_act('apache2') do |a,node|

  a << a.apache2(:any => :config, :you => :like)[:enable]

  d = AngryMob::Defaults.new( :owner => 'root', :group => 'root', :notifies => { :later => [ a.apache2[:restart] ] } )

  #a << AngryMob::Target.new_target(:dir, node.apache.log_dir, d.merge(:mode => 0755) )

  a << AngryMob::Target.new_target(:dir, "/usr/local/bin/apache2_module_conf_generate.pl".pathname, d)
  a << a.dir("/usr/local/bin/apache2_module_conf_generate.pl".pathname, d)

  #a << AngryMob::Target.new_target(:template, node.apache.dir + 'apache2.conf', :template => '')

  a.schedule_act('apache2/mod_rewrite')

  a << a.apache2[:start]
end


mob.add_act('apache2/mod_rewrite') do |a,node|
end

# attributes = Yajl::Parse.parse(somewhere)
attributes = {
  :acts => %w{apache2}
}


if $0 == __FILE__
  require 'exemplor'
  eg 'riot' do
    mob.riot!('nodename', attributes)
  end
end
