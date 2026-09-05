# frozen_string_literal: true

require File.join(__dir__, "lib", "test", "command", "version.rb")

Gem::Specification.new do |gem|
  gem.name = "test-cmd.rb"
  gem.authors = ["Robert Gleeson"]
  gem.email = ["robert@r.uby.dev"]
  gem.homepage = "https://github.com/0x1eef/test-cmd.rb#readme"
  gem.version = Test::Command::VERSION
  gem.required_ruby_version = ">= 3.0"
  gem.licenses = ["MIT"]
  gem.files = `git ls-files`.split($/)
  gem.require_paths = ["lib"]
  gem.summary = <<~SUMMARY
  test-cmd.rb is a Go-inspired, object-oriented interface for running
  commands on UNIX-like systems, in the spirit of Go's `os/exec`. A
  command can be built by chaining multiple method calls that impact
  different command attributes. The environment the command executes
  with can be set, its standard input stream can be written to, and
  the standard output and standard error streams are captured so the
  parent process can read them.
  SUMMARY
  gem.description = gem.summary
  gem.add_development_dependency "test-unit", "~> 3.5.7"
  gem.add_development_dependency "yard", "~> 0.9"
  gem.add_development_dependency "redcarpet", "~> 3.5"
  gem.add_development_dependency "standard", "~> 1.24"
  gem.add_development_dependency "rake", "~> 13.1"
end
