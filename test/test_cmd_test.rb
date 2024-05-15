require_relative "setup"

class Test::Cmd
  class Test < Test::Unit::TestCase
  end
end

class Test::Cmd
  ##
  # Test::Cmd#argv
  class ARGVTest < Test
    def test_ruby_argv
      assert_equal "42\n", cmd("ruby")
                             .argv("-e", "warn 42")
                             .stderr
    end
  end

  ##
  # Test::Cmd#{exit_status, status, success?}
  class ExitStatusTest < Test
    def test_ruby_exit_status_success
      assert_equal 0, cmd("ruby", "-e", "exit 0").exit_status
    end

    def test_ruby_exit_status_failure
      assert_equal 1, cmd("ruby", "-e", "exit 1").exit_status
    end

    def test_ruby_exit_status_predicates
      assert_equal true, cmd("ruby", "-e", "exit 0").status.success?
      assert_equal true, cmd("ruby", "-e", "exit 0").success?
    end
  end

  ##
  # Test::Cmd#{stdout,stderr}
  class OutputTest < Test
    def test_ruby_stdout
      assert_equal "42\n", cmd("ruby", "-e", "puts 42").stdout
    end

    def test_ruby_stderr
      assert_equal "42\n", cmd("ruby", "-e", "warn 42").stderr
    end

    def test_ruby_stdout_fork
      code = <<-CODE.each_line.map { _1.chomp.strip }.join(";")
      $stdout.sync = true
      fork do
        sleep(1)
        puts "bar"
      end
      puts "foo"
      Process.wait
    CODE
      assert_equal "foo\nbar\n", cmd("ruby", "-e", code).stdout
    end
  end

  ##
  # Test::Cmd#{success, failure}
  class CallbackTest < Test
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
  end

  ##
  # Test::Cmd#spawn
  class SpawnTest < Test
    def test_io_closed_after_spawn
      %i[out_io err_io].each do |io|
        assert_equal true, command.send(io).closed?
      end
    end

    def test_io_unlink_after_spawn
      %i[out_io err_io].each do |io|
        path = command.send(io).__getobj__.path
        assert_equal false, File.exist?(path)
      end
    end

    private

    def command
      cmd("ruby", "-e", "puts 42").spawn
    end
  end
end
