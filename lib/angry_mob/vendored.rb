require 'pathname'
Root = Pathname(__FILE__).dirname.join('../..').expand_path


%w{json thor angry_hash}.each do |lib|
  root = Root+'vendor'+lib
  $LOAD_PATH << (root+'lib')
end
