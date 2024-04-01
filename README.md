## About

test-cmd.rb provides an object-oriented interface for spawning 
a process.

## Examples

### Test::Unit

The following example demonstrates how tests might be written with
test-unit from the standard library. The
[`cmd`](https://0x1eef.github.io/x/test-cmd.rb/Test/CmdMixin.html#cmd-instance_method)
method takes the name or path of a command, alongside any arguments:

```ruby
require "test/unit"
require "test/cmd"

class CmdTest < Test::Unit::TestCase
  def test_ruby_stdout
    assert_equal "42\n", cmd("ruby", "-e", "puts 42").stdout
  end

  def test_ruby_stderr
    assert_equal "42\n", cmd("ruby", "-e", "warn 42").stderr
  end

  def test_ruby_success_exit_status
    assert_equal 0, cmd("ruby", "-e", "exit 0").exit_status
  end

  def test_ruby_failure_exit_status
    assert_equal 1, cmd("ruby", "-e", "exit 1").exit_status
  end
end
```

### Builder

test-cmd.rb provides an API that is similar to Rust's
[Command API](https://doc.rust-lang.org/std/process/struct.Command.html).
<br>
The
[API reference](https://0x1eef.github.io/x/test-cmd.rb)
covers it in more-depth:

``` ruby
require "test/cmd"
puts cmd("du")
       .argv("-s", "-h")
       .stdout
```

### IO#sync

Sometimes it can be neccessary to bypass Ruby's internal buffer and flush
output to the operating system immediately, otherwise there can be unexpected
results. Consider the following example, where the output will be
`bar\nfoo\n` rather than `foo\nbar\n`:

``` ruby
##
# test.rb
pid = fork do
  sleep(1)
  puts "bar"
end
puts "foo"
Process.wait(pid)

##
# cmd.rb
p cmd("ruby", "test.rb").stdout # => "bar\nfoo\n"
```

And with output flushed to the operating system immediately:

``` ruby
##
# test.rb
$stdout.sync = true
pid = fork do
  sleep(1)
  puts "bar"
end
puts "foo"
Process.wait(pid)

##
# cmd.rb
p cmd("ruby", "test.rb").stdout # => "foo\nbar\n"
```

## Documentation

A complete API reference is available at 
[0x1eef.github.io/x/test-cmd.rb](https://0x1eef.github.io/x/test-cmd.rb).

## Install

**Rubygems.org**

test-cmd.rb can be installed via rubygems.org.

    gem install test-cmd.rb

## Sources

* [GitHub](https://github.com/0x1eef/test-cmd.rb#readme)
* [GitLab](https://gitlab.com/0x1eef/test-cmd.rb#about)

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/).
<br>
See [LICENSE](./LICENSE).
