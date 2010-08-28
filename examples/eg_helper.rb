require 'rubygems'
require 'bundler'
Bundler.setup

require 'exemplor'
require 'pathname'
require 'pp'

root = Pathname('../..').expand_path(__FILE__)
$LOAD_PATH << root+'lib'

require 'angry_mob/vendored'
