%w[
  blank
  dictionary
  object
  array
  string
  pathname
  hash
  blankslate
  secure_random
].each {|lib| require "angry_mob/extend/#{lib}" }
