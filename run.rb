@home = '/root'
@sudo = false

server = 'amc-store'
@dry_run = false

case server
when 'lstaging'
  @server   = "lstaging"
  @nodename = "plus2staging-new"

when 'bho'
  @server = 'bho'
  @nodename = 'bho'

when 'amc-store'
  @home = '/home/vpsadmin'
  @server   = "amcstore"
  @nodename = "amc-store"
  @sudo = true

when 'amc-exam'
  @home = '/home/vpsadmin'
  @server   = "amcexam"
  @nodename = "amc-exam"
  @sudo = true

when 'frog'
  @server = "frog"
  @server = "root@frog"
  @nodename = "frog"

when 'frog-clean'
  @server = "frog"
  @server = "root@192.168.0.12"
  @nodename = "frog"
end

def sh(cmd)
  puts "sh: #{cmd}"
  system cmd
  raise "failed: #{cmd}" unless $?.success?
end

def rsync(from,to)
  sh "rsync -avz --exclude=.git --exclude='.*.sw?' --delete #{from}/ #{@server}:#{to}/"
end

dos = { :am => true, :p2m => true, :dna => true  }
dos = { :am => true, :p2m => true, :cm => true, :dna => true }

dos[:am]  && rsync('.'            , 'angry_mob' )
dos[:p2m] && rsync('../plus2mob'  , 'plus2mob'  )
dos[:cm]  && rsync('../common_mob', 'common_mob')

dos[:dna] && Dir.chdir("../server_dna") do
  sh("bundle exec rake json")
  sh("rsync -avz server_dna.json #{@server}:server_dna.json")
end

@nodename ||= @server

cmd = "ssh #{@server} #{'sudo' if @sudo} angry_mob/bin/mob --nodename #{@nodename} " \
      "--mob #{@home}/plus2mob --mob #{@home}/common_mob --act plus2/basics --json-file #{@home}/server_dna.json "\
      "#{'--dry-run' if @dry_run}"

puts "running with #{cmd}"
system cmd
