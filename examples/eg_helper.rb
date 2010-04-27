require 'pathname'
root = Pathname('../..').expand_path(__FILE__)
require 'pp'
require 'exemplor'
$:.unshift root+'lib'
require 'angry_hash'
