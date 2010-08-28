require 'eg_helper'
require 'angry_mob'

eg.setup do
  acts = []

  acts << AngryMob::Act.new("entry", :on => 'entry') do
    ui.log "hello from entry"

    # XXX fire()
  end

  # XXX event 'name', :mutex => {}

  acts << AngryMob::Act.new("also_entry", :on => 'entry') do
    ui.log "hello from also_entry"
  end

  acts << AngryMob::Act.new("next", :on => "finished/entry") do
    ui.log "hello after entry"
  end

  acts << AngryMob::Act.new("bottleneck", :on => %{finished/entry && finished/next}) do
    ui.log "hello bottleneck"
  end

  acts << AngryMob::Act.new("restart", :on => 'finalise') do
    ui.log "hello restart"
  end

  acts << AngryMob::Act.new("post-restart", :on => 'finalise && !something') do
    ui.log "hello post-restart"
  end

  acts << AngryMob::Act.new("post-restart-not-run", :on => 'finalise && !entry') do
    ui.log "hello post-restart-not-run"
  end

  @mob = AngryMob::Mob.new
  acts.each {|a| a.bind(@mob,'eg')}
end

eg.helpers do
end

eg 'yay' do
  @mob.riot!("eg", AngryHash[ :fire => %w{entry} ])
end
