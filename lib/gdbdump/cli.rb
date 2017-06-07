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
        pid_or_core: nil,
      }

      op.on('-d', '--[no-]debug', "print debug log (default: #{opts[:debug]})") {|v|
        opts[:debug] = v
      }
      op.on('-x', '--gdbinit FILE', "path to ruby repo's .gdbinit (default: some of ruby repo's .gdbinit are pre-bundle in this gem)") {|v|
        opts[:gdbinit] = v
      }
      op.on('--gdb PATH', "path to gdb command (default: gdb)") {|v|
        opts[:gdb] = v
      }

      op.banner += ' [ pid | /path/to/ruby pid | /path/to/ruby core ]'
      begin
        args = op.parse(argv)
      rescue OptionParser::InvalidOption => e
        usage e.message
      end

      if args.size == 1
        opts[:pid_or_core] = args[0]
      elsif args.size == 2
        opts[:ruby] = args[0]
        opts[:pid_or_core] = args[1]
      else
        usage 'number of arguments must be 1 or 2'
      end

      @opts = opts
    end

    def run
      parse_options
      GDB.new(@opts).print_backtrace
    end
  end
end
