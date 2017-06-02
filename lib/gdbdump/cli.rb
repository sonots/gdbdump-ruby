require 'optparse'
require_relative '../gdbdump'

class Gdbdump
  class CLI
    def parse_options(argv = ARGV)
      op = OptionParser.new

      self.class.module_eval do
        define_method(:usage) do |msg = nil|
          puts op.to_s
          puts "error: #{msg}" if msg
          exit 1
        end
      end

      opts = {
        debug: false,
        gdbinit: nil,
        gdb: nil,
        ruby: nil,
      }

      op.on('-d', '--[no-]debug', "print debug log (default: #{opts[:debug]})") {|v|
        opts[:debug] = v
      }
      op.on('-x', '--gdbinit FILE', "path to ruby trunk's .gdbinit (default: some of ruby trunk's .gdbinit is pre-bundle in this gem)") {|v|
        opts[:gdbinit] = v
      }
      op.on('--gdb PATH', "path to gdb command (default: gdb)") {|v|
        opts[:gdb] = v
      }
      op.on('--ruby PATH', "path to ruby which the attached process uses (default: get from /proc/[PID]/exe)") {|v|
        opts[:ruby] = v
      }

      op.banner += ' pid'
      begin
        args = op.parse(argv)
      rescue OptionParser::InvalidOption => e
        usage e.message
      end

      if args.size == 1
        @pid = args.first
      else
        usage 'number of arguments must be 1'
      end

      @opts = opts
    end

    def run
      parse_options
      GDB.new(pid: @pid, **(@opts)).print_backtrace
    end
  end
end
