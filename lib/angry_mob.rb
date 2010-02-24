require 'extend'

here = Pathname.here(__FILE__)

# vendorage... what's the best way?
$LOAD_PATH << here+'vendor/hashie-0.1.8/lib'

require 'hashie'

class AngryMob
  autoload :Mob    , 'angry_mob/mob'
  autoload :Act    , 'angry_mob/act'
  autoload :Node   , 'angry_mob/node'
  autoload :Defaults, 'angry_mob/defaults'
  autoload :Target , 'angry_mob/target'
  autoload :SingletonTarget , 'angry_mob/singleton_target'
  autoload :Builder, 'angry_mob/builder'
end
