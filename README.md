## About

test-cmd.rb provides an object-oriented interface for spawning
a command.

## Examples

### Callbacks

The success and failure callbacks provide hooks for when
a command exits successfully or unsuccessfully. The callbacks
are passed an instance of
[Test::Cmd](https://0x1eef.github.io/x/test-cmd.rb/Test/Cmd.html):

``` ruby
require "test-cmd"
cmd("ruby", "-e", "exit 0")
  .success { print "The command [#{_1.pid}] was successful", "\n" }
  .failure { print "The command [#{_1.pid}] was unsuccessful", "\n" }
```

### Test::Unit

The following example demonstrates how tests might be written with
test-unit from the standard library. The
[`cmd`](https://0x1eef.github.io/x/test-cmd.rb/Kernel.html#cmd-instance_method)
method takes the name or path of a command, alongside any arguments:

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

## Documentation

A complete API reference is available at
[0x1eef.github.io/x/test-cmd.rb](https://0x1eef.github.io/x/test-cmd.rb)

## Install

test-cmd.rb can be installed via rubygems.org:

    gem install test-cmd.rb

## Sources

* [github.com/@0x1eef](https://github.com/0x1eef/test-cmd.rb#readme)
* [gitlab.com/@0x1eef](https://gitlab.com/0x1eef/test-cmd.rb#about)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/)
<br>
See [LICENSE](./LICENSE)
