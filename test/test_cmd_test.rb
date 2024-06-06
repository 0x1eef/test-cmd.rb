require_relative "setup"

class Test::Cmd
  class Test < Test::Unit::TestCase
    private
    def ruby(str)
      cmd "ruby", "-e", str
    end
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
      assert_equal 0, ruby("exit 0").exit_status
    end

    def test_ruby_exit_status_failure
      assert_equal 1, ruby("exit 1").exit_status
    end

    def test_ruby_exit_status_predicates
      assert_equal true, ruby("exit 0").status.success?
      assert_equal true, ruby("exit 0").success?
    end
  end

  ##
  # Test::Cmd#{stdout,stderr}
  class OutputTest < Test
    def test_ruby_stdout
      assert_equal "42\n", ruby("puts 42").stdout
    end

    def test_ruby_stderr
      assert_equal "42\n", ruby("warn 42").stderr
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
      assert_equal "foo\nbar\n", ruby(code).stdout
    end
  end

  ##
  # Test::Cmd#{success, failure}
  class CallbackTest < Test
    def test_ruby_success_callback
      call_ok, call_fail = [false, false]
      ruby("exit 0")
        .success { call_ok = true }
        .failure { call_fail = true }
      assert_equal true, call_ok
      assert_equal false, call_fail
    end

    def test_ruby_failure_callback
      call_ok, call_fail = [false, false]
      ruby("exit 1")
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
        assert_equal true, spawned_command.send(io).closed?
      end
    end

    private

    def spawned_command
      ruby("puts 42").spawn
    end
  end

  ##
  # Test::Cmd#spawned?
  class SpawnedTest < Test
    def test_spawned_before_spawn
      assert_equal false, ruby("puts 42").spawned?
    end

    def test_spawned_after_spawn
      assert_equal true, ruby("puts 42").tap(&:spawn).spawned?
    end
  end
end
