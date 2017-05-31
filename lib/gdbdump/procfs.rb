require_relative 'version'

class Gdbdump
  class Procfs
    def initialize(pid)
      @pid = pid
    end

    def exe
      begin
        File.readlink("/proc/#{@pid}/exe")
      rescue Errno::ENOENT
        raise "/proc/#{@pid}/exe does not exist, it seems pid #{@pid} does not exit"
      end
    end
  end
end
