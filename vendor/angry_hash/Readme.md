# AngryHash

A stabler mash with different emphases.

# Install

    gem install angry_hash

# Usage
    grr = AngryHash[]   #=> {}
    grr = AngryHash.new #=> {}

    grr = AngryHash[ :look => { :a => ['hash'] } ]

    # reach into the hash using dot notation
    grr.look.a[0] #=> 'hash'

    # instantiate a sub-hash (idempotently):
    grr.look.another       #=> nil
    grr.look.another!.one = "nice"

    grr.look.another!.one #=> "nice"
    grr.look.another.one  #=> "nice"

    # truth in hashes
    grr.green  = true
    grr.yellow = [:goldenrod,:canary]
    grr.red    = false

    grr.green?  #=> true
    grr.yellow? #=> true
    grr.red?    #=> false
    grr.blue?   #=> false


## Merging Deeply

### Merge

Deep merges are non-destructive, as in normal hash merges.

Merge favours the other hash's keys. Reverse merge favours the target's keys.

    grr = AngryHash[ :a => {:b => :c}, :z => :x ]
    arr = AngryHash[ :a => {:d => :e}, :z => :y ]

    grr.deep_merge( arr )         #=> {"a" => {"b" => :c, "d" => :e}, "z" => :y}
    grr.reverse_deep_merge( arr ) #=> {"a" => {"b" => :c, "d" => :e}, "z" => :x}

    # grr & arr are unmodified
    grr #=> { "a" => {"b" => :c}, "z" => :x }
    arr #=> { "a" => {"d" => :e}, "z" => :y }

### Update

Deep updates replace the contents of the hash with the merged version.

They're also known as `deep_merge!` and `reverse_deep_merge!`

    grr = AngryHash[ :a => {:b => :c}, :z => :x ]
    arr = AngryHash[ :a => {:d => :e}, :z => :y ]

    grr.deep_update( arr )

    # grr is updated, arr is unmodified
    grr #=> { "a" => {"b" => :c, "d" => :e}, "z" => :y }
    arr #=> { "a" => {"d" => :e}, "z" => :y }

    grr.reverse_deep_update( arr )

    # grr is updated, arr is unmodified
    grr #=> { "a" => {"b" => :c,  "d" => :e}, "z" => :x }
    arr #=> { "a" => {"d" => :e}, "z" => :y }
    
# Extensions

`TODO` write up this section.

# Gotchas

## AngryHashes are Hashes

This is good and bad. Its good because you can use all the normal hash methods.

    AngryHash[ :a => :b, :c => :d ].each {|k,v| ... }

Unfortunately this also means that that if your hash keys collide with the names of Hash methods (or those of its ancestors) you can't use dot notation:

    h = AngryHash[ :hash => 'hooray' ]

    h.hash    #=> 12345...
    h['hash'] #=> 'hooray'
    h[:hash]  #=> 'hooray'
    
I'm planning on creating a sanitised `AngryProxy` to wrap `AngryHash`es for the times you really want guaranteed access via dot notation.

## id

Since `Object#id` is deprecated in Ruby 1.8 and has been removed in 1.9, I decided it was safe to override `id` in `AngryHash`:

    h = AngryHash[ :id => 'abc' ]

    h.id     #=> 'abc'
    h.__id__ #=> 12345...

# About

`AngryHash`'s code is hosted on GitHub and can be found at http://github.com/plus2/angry_hash

Please report problems at http://github.com/plus2/angry_hash/issues.

`AngryHash` is by Lachie Cox for PLUS2 & YesMaster.

You're free to use AngryHash under the MIT license; see License for details.
