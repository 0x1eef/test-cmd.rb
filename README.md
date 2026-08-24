<p align="center">
  <a href="https://r.uby.dev">
    <img
      src="rubydev.svg"
      width="400"
      height="200"
      border="0"
      alt="a r.uby.dev project"
     >
  </a>
</p>

> A [r.uby.dev](https://r.uby.dev) project.

Welcome to the canonical test-cmd.rb repository.

test-cmd.rb is a Go-inspired, object-oriented interface for running
commands on UNIX-like systems, in the spirit of Go's `os/exec`. A
command is built with `cmd` and `argv`, then spawned so its stdout
and stderr streams, process ID, and exit status are captured with
a background thread. Predicates like `success?`, `alive?`, and
`command_not_found?`, plus `success`/`failure` callbacks and `kill!`,
cover the common cases with a small, dependency-free API.

## Install

test-cmd.rb can be installed via rubygems.org:

    gem install test-cmd.rb

## Quick start

### Commands

The
[`cmd`](https://r.uby.dev/api-docs/test-cmd.rb/Kernel.html#cmd-instance_method)
method takes the name or path of a command, alongside any arguments.
It returns an instance of
[Test::Cmd](https://r.uby.dev/api-docs/test-cmd.rb/Test/Cmd.html)
that has access to the command's process ID, exit status,
standard output stream, and standard error stream.

```ruby
require "test-cmd"
cmd("ruby", "-e", "puts 42").stdout  # => "42\n"
```

<details>
<summary>Callbacks</summary>
<br>

The success and failure callbacks provide hooks for when
a command exits successfully or unsuccessfully. The callbacks
are passed an instance of
[Test::Cmd](https://r.uby.dev/api-docs/test-cmd.rb/Test/Cmd.html)
that has access to the command's process ID, exit status,
standard output stream, and standard error stream.

```ruby
require "test-cmd"
cmd("ruby", "-e", "exit 0")
  .success { print "The command [#{_1.pid}] was successful", "\n" }
  .failure { print "The command [#{_1.pid}] was unsuccessful", "\n" }
```
</details>

<details>
<summary>Assertions</summary>
<br>

The following example demonstrates how tests might be written with
test-unit from the standard library. The
[`cmd`](https://r.uby.dev/api-docs/test-cmd.rb/Kernel.html#cmd-instance_method)
method takes the name or path of a command, alongside any arguments. The tests
assert against the exit status, standard output stream, and standard error
stream of the spawned ruby process:

```ruby
require "test/unit"
require "test/cmd"

class CmdTest < Test::Unit::TestCase
  def test_ruby_stdout
    assert_equal "42\n", ruby("puts 42").stdout
  end

  def test_ruby_stderr
    assert_equal "42\n", ruby("warn 42").stderr
  end

  def test_ruby_success_exit_status
    assert_equal 0, ruby("exit 0").exit_status
  end

  def test_ruby_failure_exit_status
    assert_equal 1, ruby("exit 1").exit_status
  end

  private

  def ruby(code)
    cmd("ruby", "-e", code)
  end
end
```
</details>

## Documentation

A complete API reference is available at
[r.uby.dev/api-docs/test-cmd.rb](https://r.uby.dev/api-docs/test-cmd.rb)

## Sources

* [github.com/@0x1eef](https://github.com/0x1eef/test-cmd.rb#readme)
* [gitlab.com/@0x1eef](https://gitlab.com/0x1eef/test-cmd.rb#about)

## License

This software is released under the terms of the BSD Zero Clause license. <br>
See [LICENSE](./LICENSE) for details.