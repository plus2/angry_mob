require 'eg_helper'

eg 'to normal hash' do
  ah = AngryHash[:a => 1, :b => {:c => :d}]
  Assert( ah.to_normal_hash == {'a' => 1, 'b' => {'c' => :d}} )
end

eg 'to normal hash with symbol keys' do
  ah = AngryHash[:a => 1, :b => {'c' => :d}]
  Assert( ah.to_normal_hash(:symbols) == {:a => 1, :b => {:c => :d}} )
end
