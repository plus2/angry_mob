require 'eg_helper'
require 'angry_mob'



eg.helpers do
  def init
    @ui = AngryMob::UI.new(:debug => true)
    AngryMob::Rioter.ui = @ui
  end


  def load_mobs(attributes, mob_paths)
    @mob_loader = AngryMob::MobLoader.new(attributes)
    mob_paths.each {|mob_path| @mob_loader.add_mob(mob_path)}
    @mob_loader
  end


  def load_and_run(attributes, mob_paths)
    @rioter = load_mobs(attributes, mob_paths).to_rioter
    @rioter.riot!( 'example', attributes )
  end
end



eg.setup do
  init
end


eg 'loads local mob' do
  load_mobs({}, [Root+'examples/mob'])
end

eg 'builds rioter - missing mob dependency' do
  load_mobs({}, [Root+'examples/mob']).to_rioter
end

eg 'builds rioter' do
  load_mobs({}, [Root+'examples/mob', Root+'../common_mob']).to_rioter
end

eg 'runs rioter' do
  attrs = {:fire => %w{start}}
  load_and_run(attrs, [Root+'examples/mob', Root+'../common_mob'])
end
