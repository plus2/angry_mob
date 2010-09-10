require 'eg_helper'
require 'angry_hash'

module Fixtures
  module CreditCard
    def valid?
      number % 2 == 1
    end
  end
  module Course
    def shouty
      name.upcase
    end
  end

  module PhoneNumber
    def country_code
      number.to_s[/^\+(\d+)/,1].to_i
    end
  end

  module User
    include AngryHash::Extension

    extend_value :credit_card, CreditCard
    extend_array :courses, Course
    extend_hash :phone_numbers, PhoneNumber

    extend_hash :parents, User

    def shouty
      name.upcase
    end
  end

end

eg 'tracks extensions to values' do
  user = AngryHash[ :name => 'Bob', :credit_card => {:number => 123} ]
  user.extend Fixtures::User

  Assert( user.shouty == 'BOB' )
  Assert( user.credit_card.number == 123 )
  Assert( user.credit_card.valid? )

  user.credit_card.number = 456
  Assert( ! user.credit_card.valid? )
end

eg 'tracks extensions to hashes' do
  user = AngryHash[ :name => 'Bob', :credit_card => {:number => 123}, :phone_numbers => {:home => {:number => '0404555111'}, :chalet => {:number => '+12 9481 1111'}} ]
  user.extend Fixtures::User

  Assert( user.phone_numbers.home.country_code == 0 )
  Assert( user.phone_numbers.chalet.country_code == 12 )
end

eg 'tracks extensions to arrays' do
  user = AngryHash[ :name => 'Bob', :credit_card => {:number => 123}, :courses => [ {:name => 'Money for artists'}, {:name => 'Papier mache with your fortune'} ] ]
  user.extend Fixtures::User

  Assert( user.courses[0].shouty == 'MONEY FOR ARTISTS' )
  Assert( user.courses[1].shouty == 'PAPIER MACHE WITH YOUR FORTUNE' )
end

eg 'tracks deep and reflexive extensions' do
  user = AngryHash.new_extended( Fixtures::User, :name => 'Bob', 
      :parents => {
          :mum => {:name => 'Maggie', :parents => {:dad => {:name => 'Bill'}, :mum => {:name => 'Nancy'}}},
          :dad => {:name => 'John'}
      }
  )

  Assert( user.parents.mum.parents.dad.shouty == 'BILL' )
end

eg 'extensions persist with dup_with_extension' do
  user = AngryHash[ :name => 'Bob', :credit_card => {:number => 123} ]
  user.extend Fixtures::User

  Assert( user.credit_card.valid? )

  # new_user is expected to be extended
  new_user   = user.dup_with_extension

  # clean_user is expected *not* to be extended
  clean_user = user.dup

  # make sure dup worked
  Assert( user.__id__ != new_user.__id__ )
  Assert( user.__id__ != clean_user.__id__  )

  # make sure dup worked deeply
  Assert( user.credit_card.__id__ != new_user.credit_card.__id__ )
  Assert( user.credit_card.__id__ != clean_user.credit_card.__id__ )

  # the non-extended user's CC is invalid because `valid?` is accessing a nil value in the hash, rather than calling the method `valid?`
  Assert(   clean_user.credit_card.number == 123 )
  Assert( ! clean_user.credit_card.valid? )
  Assert( defined?( clean_user.credit_card.valid? ) == nil )

  # extended user's CC is valid. `valid?` refers to the method on the `CreditCard` module.
  Assert(   new_user.credit_card.number == 123 )
  Assert(   new_user.credit_card.valid? )
  Assert( defined?( new_user.credit_card.valid? ) == 'method' )
end

def same_obj(a,b)
  a.__id__ == b.__id__
end

eg 'extensions persist after deep_merge' do
  user = AngryHash[ :name => 'Bob', :credit_card => {:number => 123}, :phone_numbers => {:home => {:number => '+41 0404555111'}} ]
  user.extend Fixtures::User

  Assert( user.phone_numbers.home.country_code == 41 )

  new_user = user.deep_merge(:credit_card => {:number => 456})

  Assert( new_user.phone_numbers.home.country_code == 41 )

  Assert( ! same_obj( user.__id__, new_user.__id__ ) )
  Assert( ! same_obj( user.phone_numbers.home.__id__, new_user.phone_numbers.home.__id__ ) )

  Assert( new_user.credit_card.number == 456 )
  Assert( new_user.phone_numbers.home.country_code == 41 )
end

eg 'extensions persist after reverse_deep_merge' do
  user = AngryHash[ :name => 'Bob', :credit_card => {:number => 123}, :phone_numbers => {:home => {:number => '+41 0404555111'}} ]
  user.extend Fixtures::User

  Assert( user.phone_numbers.home.country_code == 41 )

  # Do the reverse_deep_merge
  new_user = user.reverse_deep_merge(:credit_card => {:number => 456})

  Assert( new_user.phone_numbers.home.country_code == 41 )

  Assert( ! same_obj( user.__id__, new_user.__id__ ) )
  Assert( ! same_obj( user.phone_numbers.home.__id__, new_user.phone_numbers.home.__id__ ) )

  Assert( new_user.credit_card.number == 123 )
  Assert( new_user.phone_numbers.home.country_code == 41 )
end

eg 'extensions persist after AngryHash[]' do
  user = AngryHash[ :name => 'Bob', :credit_card => {:number => 123}, :phone_numbers => {:home => {:number => '+41 0404555111'}} ]
  user.extend Fixtures::User

  user.__angry_hash_extension.tapp(:ahe)

  num = user.phone_numbers.home
  num.__angry_hash_extension.tapp(:ahe)
  
  Assert(num.country_code == 41)

  args = AngryHash[ :nothing_special => {:phone => user.phone_numbers.home} ]

  Show(args)
  Assert(args.nothing_special.phone.country_code == 41)
end
