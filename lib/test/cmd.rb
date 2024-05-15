module Test
end unless defined?(Test)

##
# test-cmd.rb provides an object oriented interface
# for spawning a command.
class Test::Cmd
  require "tempfile"
  require "securerandom"

  ##
  # @param [String] cmd
  #  A command to spawn
  # @param [Array<String>] argv
  #  Zero or more command-line arguments
  # @return [Test::Cmd]
  def initialize(cmd, *argv)
    @cmd = cmd
    @argv = argv.dup
    @status = nil
    @spawned = false
  end

  ##
  # @param [Array<String, #to_s>] argv
  #  Command-line arguments
  # @return [Test::Cmd]
  def argv(*argv)
    tap { @argv.concat(argv) }
  end

  ##
  # Spawns a command
  # @return [Test::Cmd]
  def spawn
    return self if @spawned

    tap do
      @spawned = true
      @out_io, @err_io = spawn_io
      Process.spawn(@cmd, *@argv, {out: @out_io, err: @err_io})
      Process.wait
      @status = $?
    end
  end

  ##
  # @return [String]
  #  Returns the contents of stdout
  def stdout
    @stdout ||= begin
      spawn
      out_io.tap(&:rewind).read.tap { out_io.close }
    end
  end

  ##
  # @return [String]
  #  Returns the contents of stderr
  def stderr
    @stderr ||= begin
      spawn
      err_io.tap(&:rewind).read.tap { err_io.close }
    end
  end

  ##
  # @return [Process::Status]
  #  Returns the status of a process
  def status
    spawn
    @status
  end

  ##
  # @return [Integer]
  #  Returns the process ID of a spawned command
  def pid
    status.pid
  end

  ##
  # @return [Integer]
  #  Returns the exit status of a process
  def exit_status
    status.exitstatus
  end

  ##
  # @return [Boolean]
  #  Returns true when a command exited successfully
  def success?
    status.success?
  end

  ##
  # Yields an instance of {Test::Cmd Test::Cmd}.
  #
  # @example
  #   cmd("ruby", "-e", "exit 0")
  #     .success { print "Command [#{_1.pid}] exited successfully", "\n" }
  #     .failure { }
  #
  # @return [Test::Cmd]
  def success
    tap do
      spawn
      status.success? ? yield(self) : nil
    end
  end

  ##
  # Yields an instance of {Test::Cmd Test::Cmd}.
  #
  # @example
  #   cmd("ruby", "-e", "exit 1")
  #     .success { }
  #     .failure { print "Command [#{_1.pid}] exited unsuccessfully", "\n" }
  #
  # @return [Test::Cmd]
  def failure
    tap do
      spawn
      status.success? ? nil : yield(self)
    end
  end

  private

  attr_reader :out_io, :err_io

  def spawn_io
    [
      [".testcmd.stdout.#{namespace}.", SecureRandom.alphanumeric(3)],
      [".testcmd.stderr.#{namespace}.", SecureRandom.alphanumeric(3)]
    ].map {
      file = Tempfile.new(_1)
      File.chmod(0, file.path)
      file.tap(&:unlink)
    }
  end

  def namespace
    [Process.pid, object_id].join(".")
  end
end

module Kernel
  ##
  # @param (see Test::Cmd#initialize)
  # @return (see Test::Cmd#initialize)
  def cmd(cmd, *argv)
    Test::Cmd.new(cmd, *argv)
  end
end
