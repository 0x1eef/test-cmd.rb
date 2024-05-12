require_relative "setup"

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

  def test_ruby_success_status
    assert_equal true, cmd("ruby", "-e", "exit 0").status.success?
  end

  def test_ruby_success_callback
    call_ok, call_fail = [false, false]
    cmd("ruby", "-e", "exit 0")
      .success { call_ok = true }
      .failure { call_fail = true }
    assert_equal true, call_ok
    assert_equal false, call_fail
  end

  def test_ruby_failure_callback
    call_ok, call_fail = [false, false]
    cmd("ruby", "-e", "exit 1")
      .success { call_ok = true }
      .failure { call_fail = true }
    assert_equal true, call_fail
    assert_equal false, call_ok
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
    assert_equal "foo\nbar\n", cmd("ruby", "-e", code).stdout
  end

  def test_cmd_with_argv
    assert_equal "42\n", cmd("ruby")
                           .argv("-e", "warn 42")
                           .stderr
  end
end
