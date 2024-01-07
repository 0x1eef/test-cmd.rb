require_relative "setup"

class CmdTest < Test::Unit::TestCase
  include Test::Cmd

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

  def test_stdout_with_fork
    code = <<-CODE.each_line.map { _1.chomp.strip }.join(";")
      $stdout.sync = true
      pid = fork do
        sleep(1)
        puts "bar"
      end
      puts "foo"
      Process.wait(pid)
    CODE
    assert_equal "foo\nbar\n", cmd(%Q(ruby -e '#{code}')).stdout
  end

  def test_each_line_stdout
    run = false
    cmd(%q(ruby -e '$stdout.puts "FooBar"'))
    .each_line do
      run = true
      assert_equal _1, "FooBar"
    end
    assert_equal true, run
  end

  def test_each_line_returns_enum
    assert_instance_of Enumerator,
                       cmd(%q(ruby -e '$stdout.puts "FooBar"')).each_line
  end
end
