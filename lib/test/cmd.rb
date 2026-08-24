module Test
end unless defined?(Test)

##
# test-cmd.rb provides an object oriented interface
# for spawning a command
class Test::Command
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
  # @return [Test::Command]
  def initialize(cmd, *argv)
    @cmd = cmd
    @argv = argv.dup
    @env = {}
    @status = nil
    @spawned = false
    @stdout = ""
    @stderr = ""
    @enoent = false
  end

  ##
  # @param [Array<String, #to_s>] argv
  #  Command-line arguments
  # @return [Test::Command]
  def argv(*argv)
    tap { @argv.concat(argv) }
  end

  ##
  # @param [Hash{String => String}] env
  #  Environment variables to set for the spawned command
  # @return [Test::Command]
  def env(env)
    tap { @env.merge!(env) }
  end

  ##
  # Spawns a command
  # @return [Test::Command]
  def spawn
    return self if @spawned
    tap do
      @spawned = true
      @out, @err = Pipe.pair, Pipe.pair
      ##
      # Spawn in the calling thread so the command's fds are
      # wired up before the reader thread starts. We then close
      # our own copies of the write ends so the reader thread
      # observes EOF the moment the child exits, and reads both
      # streams with whole-buffer reads rather than a byte at
      # a time.
      @pid = Process.spawn(
        @env,
        @cmd, *@argv,
        {out: @out.w, err: @err.w, in: IO::NULL}
      )
      @out.w.close
      @err.w.close
      @producer = Thread.new do
        @stdout = @out.r.read
        @stderr = @err.r.read
        Process.wait
        @status = $?
      ensure
        @out.r.close
        @err.r.close
      end
    end
  rescue Errno::ENOENT => ex
    @stderr = ex.message
    @enoent = true
    ##
    # Capture a real non-zero status so predicates like
    # #success? work even though the command never spawned.
    @status = Process.waitpid2(Process.spawn("false")).last
  end

  ##
  # @return [Process::Status]
  #  Returns the status of a process
  def status
    spawn
    consume
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
  alias_method :exitstatus, :exit_status

  ##
  # @group IO

  ##
  # @return [String]
  #  Returns the contents of stdout
  def stdout
    spawn
    consume
    @stdout
  end

  ##
  # @return [String]
  #  Returns the contents of stderr
  def stderr
    spawn
    consume
    @stderr
  end
  # @endgroup

  ##
  # @group Predicates

  ##
  # @return [Boolean]
  #  Returns true when a command exited successfully
  def success?
    status.success?
  end

  ##
  # @return [Boolean]
  #  Returns true when a command has been spawned
  def spawned?
    @spawned
  end

  ##
  # @return [Boolean]
  #  Returns true when a command is running
  def alive?
    @producer&.alive?
  end
  alias_method :running?, :alive?

  ##
  # Sends SIGKILL to a running command
  # @return [void]
  def kill!
    return unless alive?
    Process.kill("SIGKILL", @pid)
  end

  ##
  # @return [Boolean]
  #  Returns true when a command can't be found
  def command_not_found?
    spawn
    consume
    @enoent
  end
  alias_method :not_found?, :command_not_found?
  # @endgroup

  ##
  # @group Callbacks

  ##
  # @yieldparam [Test::Command] cmd
  #  Yields an instance of {Test::Command Test::Command}
  # @example
  #   Test::Command.new("ruby", "-e", "exit 0").success do
  #     print "ok pid #{_1.pid}", "\n"
  #   end
  # @return [Test::Command]
  def success
    tap do
      spawn
      consume
      status.success? ? yield(self) : nil
    end
  end

  ##
  # @yieldparam [Test::Command] cmd
  #  Yields an instance of {Test::Command Test::Command}
  # @example
  #   Test::Command.new("ruby", "-e", "exit 1").failure do
  #     print "fail pid #{_1.pid}", "\n"
  #   end
  # @return [Test::Command]
  def failure
    tap do
      spawn
      consume
      status.success? ? nil : yield(self)
    end
  end
  # @endgroup

  private

  ##
  # Blocks until the spawned command has finished, its
  # output has been read, and its exit status captured.
  # Safe to call more than once.
  # @return [void]
  def consume
    return unless @producer&.alive?
    @producer.join
  end
end