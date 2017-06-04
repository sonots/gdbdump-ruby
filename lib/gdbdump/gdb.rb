# frozen-string-literal: true
require 'open3'
require 'securerandom'
require 'shellwords'

class Gdbdump
  # GDB.new(pid: 999, debug: true).run do |gdb|
  #   puts gdb.cmd_exec('bt')
  # end
  class GDB
    COMMAND_READ_BUFFER_SIZE = 1024
    SUDO_CMD = 'sudo'

    def initialize(pid:, debug: false, gdbinit: nil, gdb: nil, ruby: nil)
      @pid = pid.to_s
      @debug = debug
      @gdb = gdb || 'gdb'
      @ruby = (ruby || Procfs.new(@pid).exe).tap do |path|
        raise "ruby #{path} is not accessible" unless File.executable?(path)
      end
      @gdbinit = (gdbinit || File.join(ROOT, 'vendor', 'ruby', ruby_minor_version, 'gdbinit')).tap do |path|
        raise "gdbinit #{path} is not readable" unless File.readable?(path)
      end
      @exec_options = [SUDO_CMD, @gdb, '-silent', '-nw', '-x', @gdbinit, @ruby, @pid]
    end

    private def ruby_version
      `#{@ruby} -e 'puts RUBY_VERSION'`.chomp
    end

    private def ruby_minor_version
      ruby_version.split('.')[0,2].join('.')
    end

    def print_rb_ps
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

    def print_backtrace

    def dumpfile
      "/tmp/gdbdump-#{@pid}"
    end

    def print_ruby_backtrace
      run do |gdb|
        out, err = gdb.cmd_exec(%Q[call rb_eval_string("#{ruby_backtrace_code}")])
        $stderr.puts err unless err.empty?
      end
    end

    def ruby_backtrace_code
      code = +%Q[File.open('#{dumpfile}', 'a') {|f|]
      code << %q[
  Thread.list.each {|th|
    f.write %Q[  Thread #{th} status=#{th.status} priority=#{th.priority}\n]
    th.backtrace.each {|bt|
      f.write %Q[      #{bt}\n]
    }
  }
}]
      code.split("\n").map(&:strip).join('; ')
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

