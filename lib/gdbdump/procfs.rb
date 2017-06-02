require_relative 'version'

class Gdbdump
  class Procfs
    def initialize(pid)
      @pid = pid
    end

    def exe
      begin
        @exe ||= File.readlink("/proc/#{@pid}/exe")
      rescue Errno::ENOENT
        raise "/proc/#{@pid}/exe does not exist, it seems no process of pid #{@pid} exists"
      end
    end
  end
end
