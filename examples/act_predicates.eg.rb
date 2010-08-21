require 'eg_helper'
require 'angry_mob'

eg 'predicate: event' do
  predicate = AngryMob::Act::Predicate.new(:on => %{event})
  Assert(   predicate.match?('event') )

  Assert(   predicate.seen?('event') )
  Assert( ! predicate.seen?('blop') )
end

eg 'predicate: event and flop' do
  predicate = AngryMob::Act::Predicate.new(:on => %{event && flop})
  #predicate = AngryMob::Act::Predicate.new(:on => %{event && flap && farp})

  #predicate = AngryMob::Act::Predicate.new(:on => %{flip || !(foo/bar && !moo)})

  #predicate = AngryMob::Act::Predicate.new(:on => %{flip || foo/bar && moo})
  #predicate = AngryMob::Act::Predicate.new(:on => %{flip && foo/bar || moo})
  

  Assert( ! predicate.match?('event') )
  Assert( ! predicate.match?('blip') )
  Assert(   predicate.match?('flop') )
end

eg 'predicate: event or flip' do
  predicate = AngryMob::Act::Predicate.new(:on => %{event || flip})

  Assert( ! predicate.match?('flop') )
  Assert(   predicate.match?('event') )

  predicate.reset!

  Assert( predicate.match?('flip') )
end
 

eg 'predicate: generic' do
  predicate = AngryMob::Act::Predicate.new(:on => %{event || flop})

  Assert( ! predicate.match?('blip') )
  Assert(   predicate.match?('flop') )
end

eg 'predicate: not event' do
  predicate = AngryMob::Act::Predicate.new(:on => %{flip && !event})

  Assert( ! predicate.match?('event') )
  Assert( ! predicate.match?('flip') )

  predicate.reset!

  Assert(   predicate.match?('flip') )
  Assert( ! predicate.match?('event') )
end

eg 'predicate: not or event' do
  predicate = AngryMob::Act::Predicate.new(:on => %{flip || !event})

  Assert( ! predicate.match?('event') )
  Assert(   predicate.match?('flip') )

  predicate.reset!

  Assert(   predicate.match?('flip') )
  Assert(   predicate.match?('event') )

  predicate.reset!
  Assert(   predicate.match?('blip') )
  Assert(   predicate.match?('event') )
end
