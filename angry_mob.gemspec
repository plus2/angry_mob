# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)
 
require 'angry_mob/version'
 
Gem::Specification.new do |s|
  s.name        = "angry_mob"
  s.version     = AngryMob::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Lachie Cox"]
  s.email       = ["lachie.cox@plus2.com.au"]
  s.homepage    = "http://github.com/plus2/angry_mob"
  s.summary     = "Automated slice configuration framework"
  s.description = "AngryMob is the automated system configuration component of YesMaster.  It combines convenient configuration data (the node), idempotent code to ensure the configuration of the parts of a system (targets), and a method of controlling the flow of the setup (acts)"
 
  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "angry_mob"
 
  # s.add_development_dependency "rspec"
 
  s.files        = Dir.glob("{bin,lib,vendor}/**/*") + %w(LICENSE README.md)
  s.executables  = ['mob']
  s.require_path = 'lib'
end
