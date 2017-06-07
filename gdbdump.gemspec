# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "gdbdump/version"

Gem::Specification.new do |spec|
  spec.name          = "gdbdump"
  spec.version       = Gdbdump::VERSION
  spec.authors       = ["Naotoshi Seo"]
  spec.email         = ["sonots@gmail.com"]

  spec.summary       = %q{Dump C level and Ruby level backtrace from living process or core file using gdb.}
  spec.description   = %q{Dump C level and Ruby level backtrace from living process or core file using gdb.}
  spec.homepage      = "https://github.com/sonots/gdbdump-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "test-unit"
end
