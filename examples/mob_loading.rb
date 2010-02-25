require 'angry_mob'
require 'exemplor'
require 'pathname'

here = Pathname(__FILE__).dirname.expand_path

eg 'load' do
  mob_loader = AngryMob::MobLoader.new

  mob_loader.load("~/dev/plus2/plus2mob")

  mob = mob_loader.to_mob

  mob.riot!( 'gigantor', {:acts => ['plus2basics']} )

  #node.targets.pretty_inspect
end
