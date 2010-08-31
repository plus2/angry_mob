require 'pathname'
here = Pathname(__FILE__).dirname

require 'angry_hash'

# XXX duckpunches aren't good for not stepping on other codes' toes
require 'angry_mob/extend'

class AngryMob
  autoload :Mob            , 'angry_mob/mob'
  autoload :Rioter         , 'angry_mob/rioter'
  autoload :Node           , 'angry_mob/node'

  autoload :Target         , 'angry_mob/target'
  autoload :SingletonTarget, 'angry_mob/singleton_target'
  autoload :Action         , 'angry_mob/action'

  autoload :Act            , 'angry_mob/act'

  autoload :Log            , 'angry_mob/log'
  autoload :UI             , 'angry_mob/ui'
  autoload :Util           , 'angry_mob/util'

  autoload :Builder        , 'angry_mob/builder'
  autoload :MobLoader      , 'angry_mob/mob_loader'

end
