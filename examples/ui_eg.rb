require 'eg_helper'
require 'angry_mob/ui'

eg.setup do
  @ui = AngryMob::UI.new
end

eg 'task' do
  task = @ui.target("Frobbing primes")
  task.log "Logging important"
  task.error "Opps 4 isn't a prime"
  task.info "Information"
  task.debug "de-emphasise"
  task.warn "warning, warning aliens approaching"

  task.skipped!
  task.changed! "hooray"

  #task.failed

  #$stdout.print "\e[1G"
  #$stdout.print "\e[31m"
  #$stdout.print "Hello there"
  #$stdout.flush

  #@ui.recolourize(:red)
end
