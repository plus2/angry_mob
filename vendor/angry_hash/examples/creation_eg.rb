require 'eg_helper'

eg.helpers do
  def oids(v)
    sub = case v 
          when Hash
            hh = {}
            v.each {|kk,vv| hh[kk] = oids(vv)}
            hh
          when Array
            v.map {|vv| oids(vv)}
          else
            v
          end

    n = {:class => v.class, :oid => v.__id__, :sub => sub}
    if v.respond_to?(:__id__)
      n[:oid] = v.__id__
    else
      n[:oid] = 0
    end
    n
  end
end

eg 'creation duplicates' do
  a1 = AngryHash[ 
    :a => { :b => 1 },
    :c => [ 1, :d, {:e => :f}, nil, true, false, 1.0, [ 'x', 'y' ] ] 
  ]
  a2 = AngryHash[ a1 ]

  pp oids(a1)
  pp oids(a2)

  Assert(a1.a.__id__ != a2.a.__id__)
  Assert(a1.c[2].__id__ != a2.c[2].__id__)
  Assert(a1.c[7].__id__ != a2.c[7].__id__)
end

#eg 'cycle detection' do
#end
