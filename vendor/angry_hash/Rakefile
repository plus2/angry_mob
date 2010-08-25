begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "angry_hash"
    gemspec.summary = "A stabler mash with different emphases."
    gemspec.description = "A stabler mash with different emphases. Used in plus2 projects AngryMob and Igor."
    gemspec.email = "lachie@plus2.com.au"
    gemspec.homepage = "http://github.com/plus2/angry_hash"
    gemspec.authors = ["Lachie Cox"]
    gemspec.test_files = Dir['examples/**/*']
    gemspec.files -= gemspec.test_files
    gemspec.executables = []
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

