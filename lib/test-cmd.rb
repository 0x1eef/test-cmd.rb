module Test
end unless defined?(Test)

##
# test-cmd.rb is a library for accessing the output streams
# (both stdout and stderr) of a spawned process. The library was
# first realized in a test environment, where it provided a path
# for verifying that when code examples are run they produce the
# expected output. The library can be generally useful outside a
# test environment, too.
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
    @out = Tempfile.new("cmd-stdout").tap(&:unlink)
    @err = Tempfile.new("cmd-stderr").tap(&:unlink)
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
  # Yields each line of stdout when the command
  # was successful, or each line of stderr when
  # the command was not successful.
  # @return [Enumerator]
  #  Returns an Enumerator when a block is not given.
  def each_line
    return enum_for(:each_line) unless block_given?
    spawn unless @spawned
    io = @status.success? ? @stdout : @stderr
    io.each_line.each { yield(_1.chomp) }
  end
end

module Test::CmdMixin
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
  include Test::CmdMixin
end
