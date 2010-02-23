Target(:sh) do
  default_action :run do
  end
end

Target(:gem) do
end

log "In plus2basics"

desc "update apt"
sh('apt-get update').if? { node.update.apt? }

pkg 'cron'

# gemmy things

gem = node.ruby.bin+'gem'

desc "update gems"
sh("#{gem} update --system").if? { node.update.gems? }

desc "add gemcutter"
sh("#{gem} sources -a 'http://gemcutter.org'").unless? { sh("#{gem} sources | grep gemcutter") }


schedule_act "iptables"
iptables_rule(:iptables_default_allows)

versions = attrs.plus2_dna.platform.versions.gems

gem 'scout', :version => versions.scout
# TODO set up scout

gem 'bundler'

schedule_act 'postgresql/client'

gem 'postgres', :version => versions.postgres

schedule_act 'mysql/client'
gem 'mysql', :version => versions.mysql

gem 'mongo', :version => versions.mongo

schedule_act 'plus2basics/features'

