unless defined?(Test)
  module Test
  end
end

##
# test-cmd.rb provides an object oriented interface
# for spawning a command.
class Test::Cmd
  ##
  # @api private
  class Pipe < Struct.new(:r, :w)
    def self.pair
      new(*IO.pipe)
    end

    def close
      [r, w].each(&:close)
    end
  end

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
    @stdout = ""
    @stderr = ""
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
      out, err = Pipe.pair, Pipe.pair
      @spawned = true
      t = Thread.new do
        Process.spawn(@cmd, *@argv, {out: out.w, err: err.w})
        Process.wait
        @status = $?
      rescue Errno::ENOENT
        @cmd, @argv = "false", []
        retry
      end
      loop do
        io, _ = IO.select([out.r, err.r], nil, nil, 0.01)
        io&.include?(out.r) ? @stdout << out.r.read(1) : nil
        io&.include?(err.r) ? @stderr << err.r.read(1) : nil
        break unless t.alive? || IO.select([out.r, err.r], nil, nil, 0.01)
      end
    ensure
      [out, err].each(&:close)
    end
  end

  ##
  # @return [String]
  #  Returns the contents of stdout
  def stdout
    spawn
    @stdout
  end

  ##
  # @return [String]
  #  Returns the contents of stderr
  def stderr
    spawn
    @stderr
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

  ##
  # @return [Boolean]
  #  Returns true when a command has been spawned
  def spawned?
    @spawned
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
