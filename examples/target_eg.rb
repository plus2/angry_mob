require 'eg_helper'
require 'angry_mob/target'
require 'angry_mob/singleton_target'

class A < AngryMob::Target
end

class B < A
end

module Ooh
  class C < AngryMob::Target
  end
end

class C < AngryMob::SingletonTarget
end


eg 'target subclasses are recorded' do
  Assert( AngryMob::Target::Tracking.subclasses == [AngryMob::Target,AngryMob::SingletonTarget,A,B,Ooh::C,C] )
end
__END__

eg 'b' do
  AngryMob::Target.new_target(:b)
end

eg 'x' do
  begin
    AngryMob::Target.new_target(:x)
  rescue
    Check(AngryMob::TargetError === $!)
  end
end

eg 'singleton' do
  instances = [
    AngryMob::Target.new_target(:c),
    AngryMob::Target.new_target(:c)
  ].map {|m| m.__id__}

  instances
end
