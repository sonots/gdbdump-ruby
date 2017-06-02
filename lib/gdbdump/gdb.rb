# frozen-string-literal: true
require 'open3'

class Gdbdump
  # GDB.new(pid: 999, prog: '/path/to/ruby', debug: true).run do |gdb|
  #   puts gdb.cmd_exec('bt')
  # end
  class GDB
    COMMAND_READ_BUFFER_SIZE = 1024
    STRINGS_CMD = 'strings'

    def initialize(pid:, prog: nil, debug: false, gdbinit: nil, gdb: nil)
      @pid = pid.to_s
      @prog = prog
      @debug = debug
      @gdbinit = gdbinit || File.join(ROOT, 'vendor', 'ruby', ruby_version, 'gdbinit')
      @gdb = gdb || 'gdb'
      @exec_options = [@gdb, '-silent', '-nw', '-x', @gdbinit, @prog, @pid]
    end

    def print_backtrace
      run do |gdb|
        out, err = gdb.cmd_exec('rb_ps')
        $stdout.puts out
        $stderr.puts err unless err.empty?
      end
      # run do |gdb|
      #   gdb.cmd_exec('call write(2, "== c backtrace ==\n", 18)')
      #   gdb.cmd_exec('call rb_print_backtrace()')
      #   gdb.cmd_exec('call write(2, "== ruby backtrace ==\n", 21)')
      #   gdb.cmd_exec('call rb_backtrace()')
      # end
    end

    def run
      @stdin, @stdout, @stderr = Open3.popen3(*@exec_options)
      if get_response =~ /ptrace: Operation not permitted/
        raise 'root privilege is required'
      end
      prepare
      begin
        yield(self)
        detach
      ensure
        Process.kill('CONT', @pid.to_i)
        @stdin.close
        @stdout.close
        @stderr.close
      end
    end

    # ToDo: Any faster way to get ruby_version from pid?
    # NOTE: I want ruby_version before starting gdb
    def ruby_version
      return @ruby_version if @ruby_version
      ret = `#{STRINGS_CMD} #{@prog}`
      line = ret.lines.find {|_| _.start_with?('RUBY_VERSION "') }
      @ruby_version = line[14..-3] if line
    end

    def cmd_exec(cmd)
      log('C', cmd)
      if cmd
        send_cmd = cmd.empty? ? cmd : "#{cmd}\n"
        r = @stdin.syswrite(send_cmd)
        raise "failed to send: [#{cmd}]" if r < send_cmd.length
      end

      get_response
    end

    def get_response
      out = +''
      loop do
        begin
          buf = @stdout.sysread(COMMAND_READ_BUFFER_SIZE)
        rescue EOFError
          break
        end
        break if buf =~ /\(gdb\) $/
        out << buf
      end
      log('O', out)

      err = +''
      loop do
        begin
          buf = @stderr.read_nonblock(COMMAND_READ_BUFFER_SIZE)
        rescue Errno::EAGAIN, Errno::EWOULDBLOCK
          break
        rescue EOFError
          break
        end
        err << buf if buf
      end
      log('E', err)

      [out, err]
    end

    private

    def prepare
      cmd_exec('set pagination off')
    end

    def detach
      cmd_exec('detach')
      cmd_exec('quit')
    end

    def log(pre, message)
      return unless @debug
      return if message.nil? or message.empty?
      message.each_line do |line|
        puts "#{pre}: #{line}"
      end
    end
  end
end

