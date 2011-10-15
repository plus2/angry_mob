class AngryMob
  # A `Builder::Act` groups target calls.
  class Act
    autoload :Scheduler     , "angry_mob/act/scheduler"
    autoload :Predicate     , "angry_mob/act/predicate"
    autoload :EventProcessor, "angry_mob/act/event_processor"
    autoload :Api           , "angry_mob/act/api"

    include Api

    attr_reader :mob, :rioter, :name, :definition_file, :options, :predicate

    NullMobInstance = NullMob.new
    BlankAct = lambda {|*|}


    def initialize(mob, *args, &blk)
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
    def bind(rioter, file)
      @rioter          = rioter
      @definition_file = file

      rioter.act_scheduler.add_act @name, self
    end


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


    def in_sub_act(*args, &blk)
      sub_act = self.class.new(NullMobInstance, "#{name}-sub-#{generate_random_name}", {:multi => true}, &blk)
      sub_act.bind(rioter, @definition_file)
      sub_act.run!(*args)
    end


    ##################################
    #  Error handling and reporting  #
    ##################################


    def raise_runtime_error(exception)
      bt = $!.backtrace
      act_line = bt.find {|line| line[/^#{this_file}:\d+:in `instance_exec'$/]}

      ui.bad "Problem running #{mob.name}:#{name}"
      ui.bad "[#{$!.class}] #{$!}"

      bt.each_with_index do |line,index|
        report_bt_line( bt[index-1] ) if line == act_line
      end

      raise $!
    end


    def report_bt_line(line)
      file,line,method = *line.split(':')

      file = Pathname(file).expand_path
      line = line.to_i

      if mob.respond_to?(:path)
        relative_file = file.relative_path_from(mob.path)
        ui.bad "in #{relative_file} at line #{line+1}"
      else
        ui.bad "in anonymous mob"
      end

      begin
        extract_code(file,line).each {|line| ui.bad line.rstrip.chomp}
      rescue
        puts "unable to extract code for #{line}"
        ui.exception!($!)
      end
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
