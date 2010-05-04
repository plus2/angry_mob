require 'rubygems'
require 'exemplor'
require 'pathname'
require 'pp'

root = Pathname(__FILE__).dirname.parent
$LOAD_PATH << root+'lib'
require 'angry_mob/vendored'
