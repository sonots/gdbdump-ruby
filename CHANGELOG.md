# 0.9.4

Enhancements:

* Support core file

# 0.9.3

Enhancements:

* Trivial enhancements of error messages

# 0.9.2

Enhancements:

* Add gdbinit of ruby 2.1 and 2.2

# 0.9.1

Enhancements:

* Get ruby version from `ruby -e 'puts RUBY_VERSION'` instead of `strings ruby | grep RUBY_VERSION` so that I do not need to assume `strings` command is available

Changes:

* Add `--ruby` option instead of `[prog pid]` argument style.

# 0.9.0

Enhancements:

* Use rb_ps defined in ruby trunk .gdbinit to
  * get backtrace of all treads
  * print backtrace to STDOUT of gdbdump process, rather than STDERR of the attached process
* Use `sudo` to execute gdb command inside so that
  * we can run as `$ gdbdump PID` rather than `$ sudo /path/to/ruby gdbdump PID`
  * (previously, it was burdensome to use rbenv rubys and bundler via sudo)

# 0.1.0

First version

* Use rb_backtrace (for ruby level backtrace) and rb_print_backtrace (for C level backtrace)
