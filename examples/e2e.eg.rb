require 'eg_helper'
require 'angry_mob'

here = Pathname(__FILE__).dirname.expand_path

def load_mob
  @mob_loader = AngryMob::MobLoader.new

  @mob_loader.add_mob("~/dev/plus2/common_mob")
  @mob_loader.builder.act('flooper') do
    sh 'ls'
  end

  @mob = @mob_loader.to_mob
end

eg 'load' do
  load_mob

  @mob.riot!('flooper', {'acts' => ['flooper']})
end
