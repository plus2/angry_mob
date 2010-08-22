require 'eg_helper'
require 'angry_mob'

eg 'mutex' do
  ep = AngryMob::Act::EventProcessor.new(:mutex => %w{restart reload})

  Show( ep.call( %w{ foo restart reload restart bar } ) )
  Show( ep.call( %w{ foo reload restart quux reload bar } ) )
  Show( ep.call( %w{ foo reload quux reload bar } ) )
  Show( ep.call( %w{ foo quux bar } ) )
end
