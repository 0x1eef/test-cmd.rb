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
test-unit from the standard library. The
[`cmd`](https://0x1eef.github.io/x/test-cmd.rb/Test/CmdMixin.html#cmd-instance_method)
method is given the name of a command, along with any arguments:

```ruby
require "test/unit"
require "test/cmd"

class CmdTest < Test::Unit::TestCase
  def test_ruby_stdout
    assert_equal "foo\n", cmd(%q(ruby -e '$stdout.puts "foo"')).stdout
  end

  def test_ruby_stderr
    assert_equal "bar\n", cmd(%q(ruby -e '$stderr.puts "bar"')).stderr
  end

  def test_ruby_success_exit_status
    assert_equal 0, cmd(%q(ruby -e 'exit 0')).exit_status
  end

  def test_ruby_failure_exit_status
    assert_equal 1, cmd(%q(ruby -e 'exit 1')).exit_status
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
str = cmd("du")
      .arg("-s").arg("-h")
      .spawn.stdout
puts str      
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

``` ruby
# Gemfile
gem "test-cmd.rb", github: "0x1eef/test-cmd.rb", tag: "v0.5.2"
```

**Rubygems.org**

test-cmd.rb can also be installed via rubygems.org.

    gem install test-cmd.rb

## License

[BSD Zero Clause](https://choosealicense.com/licenses/0bsd/).
<br>
See [LICENSE](./LICENSE).

