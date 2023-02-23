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
    assert_equal 0, cmd(%q(ruby -e 'exit 0')).status.exitstatus
  end

  def test_ruby_failure_exit_status
    assert_equal 1, cmd(%q(ruby -e 'exit 1')).status.exitstatus
  end
end
