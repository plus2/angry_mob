
class AngryMob
  class UI
    # Embed in a String to clear all previous ANSI sequences.
    CLEAR      = "\e[0m"
    # The start of an ANSI bold sequence.
    BOLD       = "\e[1m"

    # Set the terminal's foreground ANSI color to black.
    BLACK      = "\e[30m"
    # Set the terminal's foreground ANSI color to red.
    RED        = "\e[31m"
    # Set the terminal's foreground ANSI color to green.
    GREEN      = "\e[32m"
    # Set the terminal's foreground ANSI color to yellow.
    YELLOW     = "\e[33m"
    # Set the terminal's foreground ANSI color to blue.
    BLUE       = "\e[34m"
    # Set the terminal's foreground ANSI color to magenta.
    MAGENTA    = "\e[35m"
    # Set the terminal's foreground ANSI color to cyan.
    CYAN       = "\e[36m"
    # Set the terminal's foreground ANSI color to white.
    WHITE      = "\e[37m"

    GRAY      = "#{BOLD}#{BLACK}"

    BRIGHT_WHITE = "#{BOLD}#{WHITE}"

    # Set the terminal's background ANSI color to black.
    ON_BLACK   = "\e[40m"
    # Set the terminal's background ANSI color to red.
    ON_RED     = "\e[41m"
    # Set the terminal's background ANSI color to green.
    ON_GREEN   = "\e[42m"
    # Set the terminal's background ANSI color to yellow.
    ON_YELLOW  = "\e[43m"
    # Set the terminal's background ANSI color to blue.
    ON_BLUE    = "\e[44m"
    # Set the terminal's background ANSI color to magenta.
    ON_MAGENTA = "\e[45m"
    # Set the terminal's background ANSI color to cyan.
    ON_CYAN    = "\e[46m"
    # Set the terminal's background ANSI color to white.
    ON_WHITE   = "\e[47m"
    
    attr_reader :level, :result, :message, :stack

    def initialize(min_level=0, stack=[])
      @stack = stack
      @min_level = @level = min_level
      @colour = CLEAR
    end

    #def self.stack; @stack ||= [] end
    #def stack; self.class.stack end
    def current
      stack.last || self
    end

    def colourise(string, colour, bold=false)
      color = self.class.const_get(colour.to_s.upcase) if colour.is_a?(Symbol)
      bold  = bold ? BOLD : ""
      "#{bold}#{color}#{string}#{CLEAR}"
    end

    def recolourize(colour)
      $stdout.print("\e[s\e[1G#{RED}\e[u")
    end

    def say(message="", colour=nil, force_new_line=(message.to_s !~ /( |\t)$/))
      message  = message.to_s
      message  = colourise(message, colour) if colour

      if force_new_line
        $stdout.puts(message)
      else
        $stdout.print(message)
        $stdout.flush
      end
    end

    def newline
      $stdout.puts "\n"
    end

    def target(banner)
      Target.new(self,banner)
    end


    def pos
      $stdout.print("\e[6n")
      
      c = $stdin.getc
      puts "c: #{c}"

      if c == 033
        until (c = $stdin.getc) == ?R
          puts c
        end
      end

    end

    def spaces
      "  " * @level
    end

    def indent
      @level += 1
    end

    def outdent
      @level -= 1
      @level = @min_level if @level < @min_level
    end

    def info(message)
      say spaces+message, :bright_white
    end

    def good(message)
      say spaces+message, :green
    end

    def log(message)
      say spaces+message, :white
    end

    def error(message)
      say spaces+message, :red
    end
    alias_method :bad, :error

    def debug(message)
      say spaces+message, :gray
    end

    def warn(message)
      say spaces+message, :yellow
    end

    def push(message,opts={},&block)
      start! message
      subui = self.class.new(@level+1,stack)

      stack.push subui

      begin
        yield
      rescue Object
        if opts[:bubble]
          raise $!
        else
          subui.exception!($!)
        end
      end
    ensure
      stack.pop

      say spaces+'}', :yellow, false

      case subui.result
      when :ok
        say " ✓ #{message}", :green, false
        say " (#{subui.message})", :green, false if subui.message

      when :skip
        say " ● #{message}", :blue, false
        say " (#{subui.message})", :blue, false if subui.message

      when Exception
        say " ☠ #{message}", :red, false
        say " (#{subui.message})", :red, false if subui.message
        newline
        raise subui.result

      else
        say " #{message}", :gray, false
      end

      newline
    end

    def start!(banner)
      say spaces+">> ", :blue
      say banner, :white, false
      say " {", :yellow
    end

    def exception!(ex)
      msg = "[#{ex.class}] - #{ex.message}"
      say spaces+msg, :red
      # backtrace

      @result = ex
      @message = msg
    end

    def ok!(message=nil)
      @result = :ok
      @message = message
    end
    alias_method :changed!, :ok!

    def skipped!(message)
      @result = :skip
      @message = message
    end
  end
end
