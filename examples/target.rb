require 'angry_mob'
require 'exemplor'

class A < AngryMob::Target
  nickname :a
end

class B < A
  nickname :b
end

class C < AngryMob::SingletonTarget
  nickname :c
end


eg 'a' do
  AngryMob::Target.new_target(:a)
end

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
