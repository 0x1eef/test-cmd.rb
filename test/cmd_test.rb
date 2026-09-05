require_relative "setup"

class Test::Command
  class Test < Test::Unit::TestCase
    private

    def ruby(str)
      ::Test::Command.new "ruby", "-e", str
    end
  end
end

class Test::Command
  ##
  # Test::Command#argv
  class ARGVTest < Test
    def test_ruby_argv
      assert_equal "42\n", ::Test::Command.new("ruby")
                             .argv("-e", "warn 42")
                             .stderr
    end

    def test_ruby_argv_to_s
      arg = Object.new
      def arg.to_s = "-e"
      assert_equal "42\n", ::Test::Command.new("ruby")
                             .argv(arg, "warn 42")
                             .stderr
    end
  end

  ##
  # Test::Command#env
  class EnvTest < Test
    def test_ruby_env
      assert_equal "42\n",
                   ::Test::Command.new("ruby", "-e", "puts ENV['FOO']")
                     .env("FOO" => "42")
                     .stdout
    end
  end

  ##
  # Test::Command#stdin
  class StdinTest < Test
    def test_ruby_stdin_string
      assert_equal "hello world",
                   ::Test::Command.new("cat")
                     .stdin("hello world")
                     .stdout
    end

    def test_ruby_stdin_command
      assert_equal "42\n",
                   ::Test::Command.new("cat")
                     .stdin(ruby("puts 42"))
                     .stdout
    end
  end

  ##
  # Test::Command#{exit_status, status, success?}
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

    def test_nonexistent_command
      assert_equal false, ::Test::Command.new("/a/path/that/is/not/found").success?
    end
  end

  ##
  # Test::Command#{stdout,stderr}
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

    def test_nonexistent_command
      assert_equal "No such file or directory - /a/path/that/is/not/found",
                   ::Test::Command.new("/a/path/that/is/not/found").stderr
    end
  end

  ##
  # Test::Command#{success, failure}
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
  # Test::Command#spawned?
  class SpawnedTest < Test
    def test_spawned_before_spawn
      assert_equal false, ruby("puts 42").spawned?
    end

    def test_spawned_after_spawn
      assert_equal true, ruby("puts 42").tap(&:spawn).spawned?
    end
  end

  ##
  # Test::Command#command_not_found?
  class CommandNotFoundTest < Test
    def test_command_not_found
      assert_equal true, ::Test::Command.new("/a/path/that/is/not/found").command_not_found?
      assert_equal true, ::Test::Command.new("/a/path/that/is/not/found").not_found?
    end
  end
end
