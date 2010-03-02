# Server = "lstaging"
Server = "frog"

def sh(cmd)
  puts "sh: #{cmd}"
  system cmd
  raise "failed: #{cmd}" unless $?.success?
end

def rsync(from,to)
  sh "rsync -avz --exclude=.git --delete #{from}/ #{Server}:#{to}/"
end

dos = { :am => true, :p2m => true, :dna => true  }
dos = { :am => true, :p2m => true, :dna => true }

dos[:am] && rsync('.'          , 'angry_mob')
dos[:p2m] && rsync('../plus2mob', 'plus2mob')

dos[:dna] && Dir.chdir("../server_dna") do
  sh("bundle exec rake json")
  sh("rsync -avz server_dna.json #{Server}:server_dna.json")
end

system "ssh #{Server} angry_mob/bin/mob"
