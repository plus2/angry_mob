require 'eg_helper'
require 'yajl'

eg.setup do
  @a = AngryHash[
    :b => { 
      :c => 'c',
      :d => 'd' 
    }
  ]

  @b = AngryHash[
    :b => {
      :d => 'dd',
      :e => 'e'
    }
  ]
end

def same_obj(a,b)
  a.__id__ == b.__id__
end

eg 'merges' do
  merged = @a.merge(@b)

  Assert( ! same_obj( merged, @a ) )
  Assert( ! same_obj( merged, @b ) )

  Assert( ! merged.b.c? )
  Assert( merged.b.d == 'dd' )
  Assert( merged.b.e == 'e' )
end

eg 'merge dups' do
  a = AngryHash[
    :a => {:b => "cows"}
  ]
  b = AngryHash[
    :a => {:c => "bows"}
  ]

  merged = a.merge(b)

  Assert( ! same_obj( merged.a.b, a.a.b ) )
  Assert(   same_obj( merged.a.c, b.a.c ) )
end

eg 'updates' do
  merged = @a.update(@b)

  Assert(   same_obj( merged, @a ) )
  Assert( ! same_obj( merged, @b ) )

  Assert( ! merged.b.c? )
  Assert( merged.b.d == 'dd' )
  Assert( merged.b.e == 'e' )
end

eg 'deep_merge' do
  merged = @a.deep_merge(@b)

  Show(merged)

  Assert( ! same_obj( merged, @a ) )
  Assert( ! same_obj( merged, @b ) )

  Assert( merged.b.c == 'c')
  Assert( merged.b.d == 'dd')
  Assert( merged.b.e == 'e')
end

eg 'deep_update' do
  rv = @a.deep_update(@b)

  Show(@a)
  Assert(   same_obj( rv, @a ) )
  Assert( ! same_obj( @a, @b ) )

  Assert( ! rv.nil? )
  Assert( @a.b.c == 'c')
  Assert( @a.b.d == 'dd')
  Assert( @a.b.e == 'e')
end

eg 'reverse_deep_merge' do
  merged = @a.reverse_deep_merge(@b)

  Show(merged)
  Assert( ! merged.nil? )
  Assert( ! same_obj( merged, @a ) )
  Assert( ! same_obj( merged, @b ) )

  Assert( merged.b.c == 'c')
  Assert( merged.b.d == 'd')
  Assert( merged.b.e == 'e')
end

eg 'deep regression' do
  provider = AngryHash[
    :network => {
      :public => {
        :gateway => '69.164.204.1',
        :netmask => '255.255.255.0'
      },
      :private => {
        :netmask => '255.255.128.0'
      }
  }]

  server = AngryHash[
    :public_ip  => '72.14.191.135',
    :private_ip => '192.168.146.105',
    :network => {
      :public => {:gateway => '72.14.191.1'}
    }]

  server.provider = provider
  server.network!.reverse_deep_merge!(server.provider.network || {})

  Show( Yajl::Encoder.encode( server ) )
end

eg 'merge with symbol key' do
  orig = AngryHash[{
    "hosts_db"=>:db,
    "run_list"=>["role[database]"],
    "provider"=>"octopus"
  }]

  merged = orig.merge(:key=>"db")

  Show( merged )
  Assert( merged.keys[1].is_a?(String) )
end

eg 'merge regression 2' do
  other = { 'subscriptions' => [{'id' => 'fooper', 'kind' => 'topic', 'key' => 'bloop.*'}] }
  this  = AngryHash[ :whatever => 'blah blah' ]

  this.deep_update(other)

  Assert( AngryHash === this.subscriptions.first )
end
