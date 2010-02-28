require 'angry_mob'
require 'exemplor'

module Power
	def powers!
		puts "power!"
	end
end

module Puff
	def puff!
		puts "puff!"
	end
end

eg 'grudgey' do
	powers = [
		[ [:a]   , Power ],
		[ [:a,:c], [Power,Puff] ]
  ]

	g = AngryMob::AngryStruct[:a => {'b' => 1}]
  g.angry_powers = powers

	g.a.b.tapp

	g.a.powers!

	g.a.c.powers!
	g.a.c.puff!

	g.a.c.d = "hello"

	puts g.a.c.d.upcase

	g.a.c.to_hash.tapp

	g.a.b = { :good => 'bye' }

	g.a.to_hash.tapp
end

__END__
eg.setup do
	@g = AngryMob::AngryStruct[:a => {'b' => {:c => 'hello'  , :e => 'xyz'} }, :f => 1]
  @h = AngryMob::AngryStruct[:a => {:b  => {:c => 'goodbye', :d => 'bye'} }         ]
end

# eg 'cachings' do
#   a = @g.a
# 
#   # Check(a.b.__id__ == @g.a.b.__id__).is(true)
#   Check(a.b.__table.__id__ == @g.a.b.__table.__id__).is(true)
# end
 
eg 'table values' do
  x = @g.a.x

  x.y = 'hello'

  #Check(@g.a.x.y).is('hello')

  x.y += 'yellow'

  x.y.tapp('string')

  # Check(@g.a.x.y).is('helloyellow')
end
 
eg('deleting') do
  b = @g.a.b
  deleted_b = @g.a.delete(:b)

  @g.tapp

  Check(@g.a.b)
  Check(b)
  Check(deleted_b)
end


eg 'merge! !nil with !nil' do

  @g.a.merge! @h.a

  Check(@g.a.b).is( :c => 'goodbye', :d => 'bye' )
end

eg 'merge! hash with string keys' do
  @g.a.b.merge! 'c' => 'xylophone'
  Check(@g).is(:a => {:b => {:c => 'xylophone'  , :e => 'xyz'} }, :f => 1)
end


eg 'merge! nil with !nil' do
  @g.x.merge! @h.a.b
  Check(@g.x).is( :c => 'goodbye', :d => 'bye' )
end

eg 'merge! nil with nil' do
  @g.x.merge! @h.x
  Check(@g.x).is( {} )
end

eg 'merge! !nil with nil' do
  @g.a.merge! @h.x
  Check(@g.a).is( :b => {:c => 'hello', :e => 'xyz'} )
end


eg 'deep_merge! !nil with !nil' do
  @g.deep_merge! @h
  Check(@g.to_hash).is( :a => { :b => {:c => 'goodbye', :d => 'bye', :e => 'xyz' } }, :f => 1 )
end

eg 'deep_merge! stringy hash' do
  @g.deep_merge! :a => {'b' => {:f => 'food'}}
  Check(@g).is :a => {:b => {:c=>"hello", :f=>"food", :e=>"xyz"}}, :f => 1
end


eg 'deep_merge! nil with !nil' do
  @g.y.deep_merge! @h
  Check(@g.y).is( :a => {:b  => {:c => 'goodbye', :d => 'bye'} } )
end


eg 'deep_merge! for proxies' do
  old_b = @g.a.b

  @g.deep_merge! @h

  Check(old_b.to_hash == @g.a.b.to_hash).is true
end

eg 'proxies!' do
  target = AngryMob::AngryStruct.new

  x = target.x
  y = x.y
  z = y.z

  target.x = { :y => { :z => 'hello' } }

  target.tapp(:after)

  Check(z)
end

eg 'deeper' do
  target = AngryMob::AngryStruct[ :e => {:f => :g} ]
  mix = AngryMob::AngryStruct[ :a => {:b => {:c => :d}} ]

  x = target.a.b

  target.deep_merge! mix

  Check(x).is( :c => :d )
  Check(target.a.b).is( :c => :d )
  Check(target.a.b).is(x)
end

# reverse
eg 'reverse_deep_merge! !nil with !nil' do
  @g.reverse_deep_merge! @h
  Check(@g).is( :a => { :b => {:c => 'hello', :d => 'bye', :e => 'xyz' } }, :f => 1 )
end

__END__
eg 'reverse_deep_update! nil with !nil' do
  #@g.y.reverse_deep_update! @y
end
