require 'extend'

here = Pathname.here(__FILE__)

class AngryMob
  autoload :AngryStruct    , 'angry_mob/angry_struct'

  autoload :Mob            , 'angry_mob/mob'
  autoload :Node           , 'angry_mob/node'

  autoload :Target         , 'angry_mob/target'
  autoload :SingletonTarget, 'angry_mob/singleton_target'

  autoload :Log            , 'angry_mob/log'

  autoload :Builder        , 'angry_mob/builder'
  autoload :MobLoader      , 'angry_mob/mob_loader'

end
