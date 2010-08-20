require 'eg_helper'
require 'angry_mob'

eg.setup do
  acts = []

  acts << AngryMob::Act.new("entry", :on => :entry) do
    ui.log "hello from entry"
  end

  acts << AngryMob::Act.new("also_entry", :on => :entry) do
    ui.log "hello from also_entry"
  end

  acts << AngryMob::Act.new("next", :on => "finished/entry") do
    ui.log "hello after entry"
  end

  acts << AngryMob::Act.new("bottleneck", :on_all => %w{finished/entry finished/next}) do
    ui.log "hello bottleneck"
  end

  @mob = AngryMob::Mob.new
  acts.each {|a| a.bind(@mob,'eg')}
end

eg.helpers do
end

eg 'yay' do
  @mob.riot!("eg", AngryHash[ :fire => %w{entry} ])
end
