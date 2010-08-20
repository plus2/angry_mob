require 'eg_helper'
require 'angry_mob'

eg 'predicate: event' do
  predicate = AngryMob::Act::Predicate.new(:on_all => %w{event})
  Assert(   predicate.match?('event') )

  Assert(   predicate.seen?('event') )
  Assert( ! predicate.seen?('blop') )
end

eg 'predicate: event and flop' do
  predicate = AngryMob::Act::Predicate.new(:on_all => %w{event flop})

  Assert( ! predicate.match?('event') )
  Assert( ! predicate.match?('blip') )
  Assert(   predicate.match?('flop') )
end

eg 'predicate: event or flip' do
  predicate = AngryMob::Act::Predicate.new(:on_any => %w{event flip})

  Assert( ! predicate.match?('flop') )
  Assert(   predicate.match?('event') )

  predicate.reset!

  Assert( predicate.match?('flip') )
end

eg 'predicate: generic' do
  predicate = AngryMob::Act::Predicate.new(:on => [:or, :event, :flop])

  Assert( ! predicate.match?('blip') )
  Assert(   predicate.match?('flop') )
end
