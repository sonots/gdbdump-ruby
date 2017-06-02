require_relative "gdbdump/version"

class Gdbdump
  ROOT = File.dirname(File.dirname(__FILE__))
end

require_relative "gdbdump/gdb"
require_relative "gdbdump/procfs"
