require 'angry_mob'
require 'exemplor'

root = Pathname.here(__FILE__).parent

mob_loader = AngryMob::MobLoader.new
mob_loader.load(root.parent+"plus2mob")
mob = mob_loader.to_mob

mob.target_classes.tapp(:target_classes)
mob.acts.tapp(:acts)
