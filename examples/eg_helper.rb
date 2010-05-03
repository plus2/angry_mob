require 'pathname'
root = Pathname('../..').expand_path(__FILE__)
require 'pp'
$:.unshift root+'lib'
require root+'lib/angry_hash'

require 'rubygems'
require 'exemplor'
