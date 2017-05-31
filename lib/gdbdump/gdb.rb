require 'open3'

class Gdbdump
  # GDB.new(pid: 999, prog: '/path/to/ruby', debug: true).run do |gdb|
  #   puts gdb.cmd_exec('bt')
  # end
  class GDB
    COMMAND_READ_BUFFER_SIZE = 1024

    def initialize(pid:, prog:, debug: false)
      @prog = prog
      @pid = pid.to_s
      @debug = debug
      @exec_options = ['gdb', '-silent', '-nw', @prog, @pid]
    end

    def print_backtrace
      run do |gdb|
        gdb.cmd_exec('call write(2, "== c backtrace ==\n", 18)')
        gdb.cmd_exec('call rb_print_backtrace()')
        gdb.cmd_exec('call write(2, "== ruby backtrace ==\n", 21)')
        gdb.cmd_exec('call rb_backtrace()')
      end
    end

    def run
      @stdin, @stdout, @stderr = Open3.popen3(*@exec_options)
      if get_response =~ /ptrace: Operation not permitted./
        raise 'Must run gdbdump with sudo'
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
      response = +''

      loop do
        begin
          buf = @stdout.sysread(COMMAND_READ_BUFFER_SIZE)
        rescue EOFError
          break
        end
        response << buf
        break if buf =~ /\(gdb\) $/
      end

      loop do
        begin
          buf = @stderr.read_nonblock(COMMAND_READ_BUFFER_SIZE)
        rescue Errno::EAGAIN, Errno::EWOULDBLOCK
          break
        rescue EOFError
          break
        end
        response << buf if buf
      end

      log('R', response)
      response
    end

    private

    def prepare
      cmd_exec('')
      cmd_exec('set pagination off')
    end

    def detach
      cmd_exec('detach')
      cmd_exec('quit')
    end

    def log(pre, message)
      return unless @debug
      message.each_line do |line|
        puts "#{pre}: #{line}"
      end
    end
  end
end

