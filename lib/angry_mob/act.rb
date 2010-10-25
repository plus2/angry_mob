class AngryMob
  # A `Builder::Act` groups target calls.
  class Act
    autoload :Scheduler     , "angry_mob/act/scheduler"
    autoload :Predicate     , "angry_mob/act/predicate"
    autoload :EventProcessor, "angry_mob/act/event_processor"

    attr_reader :mob, :rioter, :name, :definition_file, :options, :predicate

    NullMobInstance = NullMob.new
    BlankAct = lambda {|*|}

    def initialize(mob,*args,&blk)
      @mob     = mob
      @options = args.extract_options!
      @name    = args.shift || generate_random_name

      @multi   = !! options.delete(:multi)
      @blk     = block_given? ? blk : BlankAct

      parse_predicate!
    end

    def parse_predicate!
      begin
        @predicate = Predicate.build( options.slice(:on,:on_all,:on_any) )
      rescue Citrus::ParseError
        puts "error creating predicate on act #{name} #{options[:definition_file]}"
        raise $!
      end
    end

    def ui; mob.ui end
    def log(message); mob.ui.log message end

    def multi?; !!@multi end

    def match?(event)
      @predicate.match?(event)
    end

    # Binds the act to the rioter and the file from which it came.
    def bind(rioter,file)
      @rioter          = rioter
      @definition_file = file

      rioter.act_scheduler.add_act @name, self
    end

    #### Compilation

    # Executes the block via `instance_exec`
    def run!(*arguments)
      ui.push("act '#{name}'", :bubble => true) do
        @running = true

        begin
          instance_exec *arguments, &@blk
        rescue
          raise_runtime_error($!)
        end

        @running = false
      end
    end

    # bundler + rubygems clusterfuck
    def gem(*args,&blk)
      __run_target(:gem,*args,&blk)
    end

    # TODO - de-mm
    def method_missing(nickname,*args,&blk)
      return super unless @running
      __run_target(nickname,*args,&blk)
    end

    # Locates and calls a `Target::Call` (which wraps a `Target`).
    # The wrapped `Target` is returned.
    def __run_target(nickname,*args,&blk)
      call = rioter.target_mother.target_call(nickname,*args,&blk)

      call.merge_defaults(defaults.defaults_for(nickname))
      call.call(self)

      call.target
    end

    def in_sub_act(*args,&blk)
      sub_act = self.class.new(NullMobInstance, "#{name}-sub-#{generate_random_name}", {:multi => true}, &blk)
      sub_act.bind(rioter,@definition_file)
      sub_act.run!(*args)
    end

    def raise_runtime_error(exception)
      bt = $!.backtrace
      act_line = bt.find {|line| line[/^#{this_file}:\d+:in `instance_exec'$/]}
      act_index = bt.rindex(act_line)

      file,line,method = *bt[act_index-1].split(':')

      file = Pathname(file)
      line = line.to_i

      relative_file = file.relative_path_from(mob.path)

      ui.bad "Problem running #{mob.name}:#{name} #{relative_file} at line #{line+1}"

      begin
        extract_code(file,line).each {|line| ui.bad line.rstrip.chomp}
      rescue
        puts "unable to extract code"
        ui.exception!($!)
      end

      raise $!
    end

    def extract_code(file,line,context=3)
      lines = file.open.readlines
      from  = [ line-3, 0 ].max
      to    = [ line+3, lines.size-1 ].min

      (from..to).map do |i|
        "%s %3d %s" % [(i+1==line ? '>':' '),i+1,lines[i]]
      end
    end

    def this_file
      File.expand_path(__FILE__)
    end

    #### Definition helpers

    def defaults
      @defaults ||= Target::Defaults.new
    end

    def node
      rioter.node
    end

    def act_now act_name, *args
      rioter.act_scheduler.act_now act_name, *args
    end

    def fire event_name
      rioter.act_scheduler.fire event_name
    end

    def schedule_act act_name
      raise "to remove"
    end

    protected
    def generate_random_name
      if definition_file
        "act-#{Util.snake_case(definition_file.to_s.split('/').last)}-#{SecureRandom.hex(10)}"
      else
        "act-#{SecureRandom.hex(10)}"
      end
    end
  end
end
