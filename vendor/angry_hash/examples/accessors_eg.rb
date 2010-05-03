require 'eg_helper'

eg.setup do
  @a = AngryHash[
    :b => { 
      :c => 'c',
      :d => 'd' 
    }
  ]
end

def same_obj(a,b)
  a.__id__ == b.__id__
end

eg 'accessor! with existing subhash' do
  Assert( same_obj( @a.b!, @a.b ) )
end

eg 'accessor! creating and returning' do
  d = @a.d!
  Assert( same_obj( d, @a.d ) )
end

eg 'accessor= AngryHash' do
  d    = AngryHash.new
  @a.d = d
  Assert( same_obj( d, @a.d ) )
end

eg 'accessor= Hash' do
  d = {}
  @a.d = d
  Assert( ! same_obj( d, @a.d ) )
end
