%w[
  blank
  dictionary
  object
  array
  string
  pathname
  hash
  blankslate
].each {|lib| require "angry_mob/extend/#{lib}" }
