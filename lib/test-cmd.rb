module Test
end unless defined?(Test)

##
# test-cmd.rb provides an object oriented interface
# for spawning a command.
class Test::Cmd
  require "tempfile"

  ##
  # @param [String] cmd
  #  A command to spawn
  # @param [Array<String>] argv
  #  Zero or more command-line arguments
  # @return [Test::Cmd]
  def initialize(cmd, *argv)
    @cmd = cmd
    @argv = argv.dup
    @out = unlink!(Tempfile.new("cmd-stdout"))
    @err = unlink!(Tempfile.new("cmd-stderr"))
    @status = nil
    @spawned = false
  end

  ##
  # @param [Array<String, #to_s>] argv
  #  Command-line arguments
  # @return [Test::Cmd]
  def argv(*argv)
    tap do
      @argv.concat(argv)
    end
  end

  ##
  # Spawns a command
  # @return [Test::Cmd]
  def spawn
    tap do
      @spawned = true
      Process.wait Process.spawn(@cmd, *@argv, {out: @out, err: @err})
      @status = $?
    end
  ensure
    [stdout,stderr]
  end

  ##
  # @return [String]
  #  Returns the contents of stdout
  def stdout
    spawn unless @spawned
    @stdout ||= @out.tap(&:rewind).read
  ensure
    @out.close unless @out.closed?
  end

  ##
  # @return [String]
  #  Returns the contents of stderr
  def stderr
    spawn unless @spawned
    @stderr ||= @err.tap(&:rewind).read
  ensure
    @err.close unless @err.closed?
  end

  ##
  # @return [Process::Status]
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

module Kernel
  ##
  # @param (see Test::Cmd#initialize)
  # @return (see Test::Cmd#initialize)
  def cmd(cmd, *argv)
    Test::Cmd.new(cmd, *argv)
  end
end
