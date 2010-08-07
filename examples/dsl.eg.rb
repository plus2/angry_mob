require 'eg_helper'

eg 'eval a block as dsl' do
  original = AngryHash[ :a => 'x', :b => {:c => 1}, :d => 'z' ]

  original.__eval_as_dsl do
    foo 'bar'
    a 'y'
    b :e => 2
  end

  Assert(original.foo == 'bar')
  Assert(original.a   == 'y')
  Assert(original.d   == 'z')

  Assert(original.b.c == 1)
  Assert(original.b.e == 2)
end
