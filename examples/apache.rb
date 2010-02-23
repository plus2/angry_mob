SingletonTarget(:service) do
  known_actions :start, :stop, :enable, :disable
end

module DebianService
  action :enable do
  end

  action :disable do
  end

  def enabled?
  end
end

service("apache2") do
  include DebianService

  action :start do
    sh "apache2ctl -k start" unless started?
  end

  action :stop do
    sh "apache2ctl -k stop" if started?
  end

  def started?
    sh('apache2ctl status').ok?
  end
end

module FileOwnership
  chown(owner) unless owner.nil?
  chgrp(group) unless group.nil?
  chmod(mode ) unless mode.nil?
end

Target(:dir) do
  include FileOwnership

  # XXX - build state
  state do
  end

  # XXX - if state block missing, just run

  def default_object
    # XXX
  end

  default_action :make do
    mkpath unless exist?
    set_ownership
  end

  action :del do
    #
  end
end

Target(:template) do
  include FileOwnership
  default_action :make do
    # creaty
    set_ownership
  end
end

defaults.node(
  :apache => { :dir => '/etc/apache2'.pathname }
)

dir(node.apache.log_dir, :mode => 0700)

defaults.dir(:user => 'root', :group => 'root', :mode => 0755) do

  file("/usr/local/bin/apache2_module_conf_generate.pl".pathname, :src => 'apache2_module_conf_generate.pl')

  %w{sites-available sites-enabled mods-available mods-enabled}.each do |sub_dir|
    dir(node.apache.dir + sub_dir)
  end
end

defaults.template(:owner => 'root', :group => 'root', :mode => 0644, :notifies => apache2.restart!) do
  template node.apache.dir + 'apache2.conf'   , :src => 'apache2.conf.erb'
  template node.apache.dir + 'conf.d/security', :src => 'security.erb'
end

