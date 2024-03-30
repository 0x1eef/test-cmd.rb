module Test
end unless defined?(Test)

##
# test-cmd.rb is a library for accessing the output streams
# (both stdout and stderr) of a spawned process.
class Test::Cmd
  require "tempfile"

  ##
  # @param [String] cmd
  #  A command to spawn.
  # @param [Array<String>] args
  #  An array of command-line arguments.
  # @return [Test::Cmd]
  def initialize(cmd, args = [])
    @cmd = cmd
    @args = args.dup
    @out = unlink!(Tempfile.new("cmd-stdout"))
    @err = unlink!(Tempfile.new("cmd-stderr"))
    @status = nil
    @spawned = false
  end

  ##
  # @param [String, #to_s] arg
  #  A command-line argument.
  # @return [Test::Cmd]
  def arg(arg)
    tap do
      @args.push(arg)
    end
  end

  ##
  # @param [Array<String, #to_s>] args
  #  One or more command-line arguments.
  # @return [Test::Cmd]
  def args(*args)
    tap do
      @args.concat(args)
    end
  end

  ##
  # Spawns a command.
  # @return [Test::Cmd]
  def spawn
    tap do
      @spawned = true
      Process.wait Process.spawn(@cmd, *@args, {out: @out, err: @err})
      @status = $?
    end
  ensure
    [stdout,stderr]
  end

  ##
  # @return [String]
  #  Returns the contents of stdout.
  def stdout
    spawn unless @spawned
    @stdout ||= @out.tap(&:rewind).read
  ensure
    @out.close unless @out.closed?
  end

  ##
  # @return [String]
  #  Returns the contents of stderr.
  def stderr
    spawn unless @spawned
    @stderr ||= @err.tap(&:rewind).read
  ensure
    @err.close unless @err.closed?
  end

  ## @return [Process::Status]
  #  Returns the status of a process
  def status
    spawn unless @spawned
    @status
  end

  ##
  # @return [Integer]
  #  Returns the exit status of a process
  def exit_status
    status.exitstatus
  end

  ##
  # @param [Symbol] io
  #  The output stream as a Symbol (:stdout, :stderr).
  # @return [Enumerator]
  #  Returns an Enumerator when a block is not given.
  def each_line(io = :stdout)
    return enum_for(:each_line, io) unless block_given?
    spawn unless @spawned
    public_send(io).each_line { yield(_1) }
  end

  private

  ##
  # @api private
  def unlink!(file)
    file.tap do
      File.chmod(0, file.path)
      file.unlink
    end
  end
end

module Test::Cmd::Mixin
  ##
  # @param [String] cmd
  #  A command to execute
  # @param [Array<String>] args
  #  An array of command-line arguments.
  # @return [Test::Cmd]
  #  Returns an instance of {Test::Cmd Test::Cmd}
  def cmd(cmd, args = [])
    Test::Cmd.new(cmd, args)
  end
end

module Kernel
  include Test::Cmd::Mixin
end
