# Gdbdump

Print C level and Ruby level backtrace of living process using gdb

## Installation

    $ gem install gdbdump

## Requirements

* run with sudo.
* on Linux.

I verified that this gem works with ruby executables built by [rbenv/ruby-build](https://github.com/rbenv/ruby-build).

## Example

With living ruby process of pid 1897,

```
$ sudo gdbdump 1897
```

You will see C and Ruby level backtrace on STDERR of **the target process** of pid 1897 as:

```
== c backtrace ==
/home/ubuntu/.rbenv/versions/2.4.1/bin/ruby(rb_print_backtrace+0x15) [0x7fd23062c115] vm_dump.c:684
[0x7ffc98c378af]
== ruby backtrace ==
        from loop.rb:3:in `<main>'
        from loop.rb:3:in `loop'
        from loop.rb:5:in `block in <main>'
        from loop.rb:5:in `sleep'
```

## Usage

```
Usage: gdbdump [options] [pid|prog pid]
    -d, --[no-]debug                 print debug log (default: false)
```

## How this work

Attach to the ruby process with gdb, and call `rb_print_backtrace()` (C level backtrace) and `rb_backtrace()` (Ruby level backtrace). That's it.

The path of ruby executable is found by `/proc/[PID]/exe` as default.

## ToDo

* Want to print backtrace on STDOUT of gdbdump process.
  * To do it, we need another version of `rb_print_backtrace` and `rb_backtrace` to print results into a file in CRuby itself.
  * If they are available, gdbdump can dump to a file and, then read and print into STDOUT of gdbdump process.

## Comparisons

* gdb
  * You can get C level backtrace with raw gdb, of course.
* [sigdump](https://github.com/frsyuki/sigdump)
  * You can get ruby level backtrace with sigdump gem, but your ruby application must pre-install sigdump and `require 'sigdump/setup'`. `gdbdump` does not require it.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sonots/gdbdump. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gdbdump project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/gdbdump/blob/master/CODE_OF_CONDUCT.md).
