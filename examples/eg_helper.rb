require 'rubygems'
require 'bundler'
Bundler.setup

require 'exemplor'
require 'pathname'
require 'pp'

Root = Pathname('../..').expand_path(__FILE__)
$LOAD_PATH << Root+'lib'

require 'angry_mob/vendored'
