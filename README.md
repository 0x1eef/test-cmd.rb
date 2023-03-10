## About

test-cmd.rb is a library for accessing the output streams
(both stdout and stderr) of a spawned process. The library was
first realized in a test environment, where it provided a path
for verifying that when code examples are run they produce the
expected output. The library can be generally useful outside a
test environment, too.

## Examples

### Test::Unit

The following example demonstrates how tests might be written with
test-unit from the standard library. The [`Test::Cmd`](#link) module
implements a [`cmd`](#link) method that can be included into a
testcase. The [`cmd`](#link) method takes the command to run as
its first and only argument:

```ruby
require "test/unit"
require "test/cmd"

class CmdTest < Test::Unit::TestCase
  include Test::Cmd

  def test_ruby_stdout
    assert_equal "foo\n", cmd(%q(ruby -e '$stdout.puts "foo"')).stdout
  end

  def test_ruby_stderr
    assert_equal "bar\n", cmd(%q(ruby -e '$stderr.puts "bar"')).stderr
  end

  def test_ruby_success_exit_status
    assert_equal 0, cmd(%q(ruby -e 'exit 0')).status.exitstatus
  end

  def test_ruby_failure_exit_status
    assert_equal 1, cmd(%q(ruby -e 'exit 1')).status.exitstatus
  end
end
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
p cmd("ruby test.rb").stdout # => "bar\nfoo\n"
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
p cmd("ruby test.rb").stdout # => "foo\nbar\n"
```

## Sources

* [Source code (GitHub)](https://github.com/0x1eef/test-cmd.rb#readme)
* [Source code (GitLab)](https://gitlab.com/0x1eef/test-cmd.rb#about)

## Install

test-cmd.rb is distributed as a RubyGem through its git repositories. <br>
[GitHub](https://github.com/0x1eef/test-cmd.rb),
and
[GitLab](https://gitlab.com/0x1eef/test-cmd.rb)
are available as sources.

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/).
<br>
See [LICENSE](./LICENSE).

