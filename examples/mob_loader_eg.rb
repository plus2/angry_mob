require 'eg_helper'
require 'angry_mob'

here = Pathname(__FILE__).dirname.expand_path

def load_mob
  @mob_loader = AngryMob::MobLoader.new

  @mob_loader.add_mob("~/dev/plus2/plus2mob")
  @mob_loader.add_mob("~/dev/plus2/common_mob")

  @mob = @mob_loader.to_mob
end

eg 'load' do
  load_mob

  Show( @mob_loader.mobs )
  Show( @mob_loader.loaded_mobs )
  Show( AngryMob::Target::Tracking.subclasses.map {|s| s.to_s} )
  Assert( ! (AngryMob::Target::Tracking.subclasses - [AngryMob::Target]).empty? )


  # mob.riot!( 'gigantor', {:acts => ['plus2basics']} )

  # node.targets.pretty_inspect
end
