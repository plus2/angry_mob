require 'pathname'
here = Pathname(__FILE__).dirname

require 'angry_mob/extend'

class AngryMob
  autoload :AngryHash    , 'angry_mob/angry_struct'

  autoload :Mob            , 'angry_mob/mob'
  autoload :Node           , 'angry_mob/node'

  autoload :Target         , 'angry_mob/target'
  autoload :SingletonTarget, 'angry_mob/singleton_target'

  autoload :TargetScheduler, 'angry_mob/target_scheduler'
  autoload :ActScheduler   , 'angry_mob/act_scheduler'

  autoload :Log            , 'angry_mob/log'

  autoload :Builder        , 'angry_mob/builder'
  autoload :MobLoader      , 'angry_mob/mob_loader'

end
