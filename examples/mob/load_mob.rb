name 'example_mob'

depends_on_mob 'common_mob', :sha => ''
# depends_on_mob 'common_mob', :gem_version => '~> 0.2.0'


build do |root|
  add_lib          root+'lib'
  add_targets_from root+'targets'
  add_acts_from    root+'acts'
end
