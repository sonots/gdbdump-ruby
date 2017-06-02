# gdbdump

Print C level and Ruby level backtrace of living ruby process using gdb

## Installation

```
$ gem install gdbdump
```

## Requirements

* gdb
* linux
* `sudo gdb` must be allowed

It was verfied that gdbdump works with ruby executables built by [rbenv/ruby-build](https://github.com/rbenv/ruby-build).

## Usage

```
Usage: gdbdump [options] [pid|prog pid]
    -d, --[no-]debug   print debug log (default: false)
    -x, --gdbinit FILE path to ruby trunk's .gdbinit (default: some of ruby trunk's .gdbinit is bundle in this gem, and used})
        --gdb PATH     path to gdb command (default: gdb)
```

### .gdbinit

Default supported ruby versions: 2.3.0 - 2.4.1

Ruby trunk's [.gdbinit](https://github.com/ruby/ruby/blob/trunk/.gdbinit) file defines useful helper functions and it is maintained by ruby core team. `gdbdump` uses it.
Some versions of .gdbinit are bundled in this gem, but if you want to use `gdbdump` for older or newer ruby versions:

1. Download .gdbinit from ruby repo like https://github.com/ruby/ruby/blob/v2_4_1/.gdbinit, and specify with `-x` option
2. Or, send PR to bundle the .gdbinit in `gdbdump` gem.

## Example

With living ruby 2.4.1 process of pid 1897,

```
$ gdbdump 1897
```

You will see C and Ruby level backtrace as:

```
$1 = (rb_vm_t *) 0x7f46bb071f20
* #<Thread:0x7f46bb0a5ee8 rb_thread_t:0x7f46bb0725d0 native_thread:0x7f46ba514740>
0x7f46ba16d700 <thread_join_m at thread.c:980>:in `join'
loop.rb:17:in `<main>'
* #<Thread:0x7f46bb202750 rb_thread_t:0x7f46bb3e03d0 native_thread:0x7f46b89c0700>
0x7f46ba0e4f30 <rb_f_sleep at process.c:4388>:in `sleep'
loop.rb:6:in `block (2 levels) in <main>'
0x7f46ba1a72b0 <rb_f_loop at vm_eval.c:1137>:in `loop'
loop.rb:4:in `block in <main>'
* #<Thread:0x7f46bb202660 rb_thread_t:0x7f46bb3e47e0 native_thread:0x7f46b87be700>
0x7f46ba0e4f30 <rb_f_sleep at process.c:4388>:in `sleep'
loop.rb:13:in `block (2 levels) in <main>'
0x7f46ba1a72b0 <rb_f_loop at vm_eval.c:1137>:in `loop'
loop.rb:11:in `block in <main>'
```

## FAQ

* Q. How this work?
  * A. Attach to the ruby process with gdb, and call `rb_ps` defined in gdbinit. That's it.
* Q. Is this available for production process?
  * A. GDB stops the process during printing backtrace, would cause some issues

## Comparisons

* gdb
  * You can print C level backtrace with raw gdb, of course
* [sigdump](https://github.com/frsyuki/sigdump)
  * sigdump enables to print ruby level backtrace with sending CONT signal to living ruby process.
  * The ruby process must pre-install `sigdump` gem and `require 'sigdump/setup'` unlike gdbdump.
  * sigdump prints backtrace in signal handler, so blocks main thread, but other threads still work unlike gdbdump.
* [gdbruby](https://github.com/gunyarakun/gdbruby)
  * gdbruby enables to print C level and ruby level backtrace of living ruby process and core file.
  * gdbruby must follow changes of C level interfaces of CRuby to get backtrace of the core file, it rises fragility that it will be broken on newer ruby versions.
  * gdbruby stops the process during printing backtrace as gdbdump, but it supports also core file. Using `gcore` command to get core file, it would be possible to analyze without stopping the process.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sonots/gdbdump. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gdbdump project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/gdbdump/blob/master/CODE_OF_CONDUCT.md).
