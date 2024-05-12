require_relative "../test-cmd"

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
    @status = nil
    @spawned = false
    @out, @err = [%w[testcmd stdout], %w[testcmd stderr]].map {
      file = Tempfile.new(_1)
      File.chmod(0, file.path)
      file.tap(&:unlink)
    }
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
    return if @spawned

    tap do
      @spawned = true
      Process.spawn(@cmd, *@argv, {out: @out, err: @err})
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
      @out.tap(&:rewind).read.tap { @out.close }
    end
  end

  ##
  # @return [String]
  #  Returns the contents of stderr
  def stderr
    @stderr ||= begin
      spawn
      @err.tap(&:rewind).read.tap { @err.close }
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
  #  Returns the exit status of a process
  def exit_status
    status.exitstatus
  end
end
