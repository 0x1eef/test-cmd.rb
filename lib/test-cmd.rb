module Test
end unless defined?(Test)

##
# test-cmd.rb is a library for accessing the output streams
# (both stdout and stderr) of a spawned process. The library was
# first realized in a test environment, where it provided a path
# for verifying that when code examples are run they produce the
# expected output. The library can be generally useful outside a
# test environment, too.
module Test::Cmd
  class Result
    require "tempfile"
    ##
    # @return [String]
    #  Returns the contents of stdout
    attr_reader :stdout

    ##
    # @return [String]
    #  Returns the contents of stderr
    attr_reader :stderr

    ## @return [Process::Status]
    #  Returns the status of a process
    attr_reader :status

    ##
    # @param [Tempfile] stdout
    # @param [Tempfile] stderr
    # @param [Process::Status] pstatus
    # @return [Test::Cmd::Result]
    def initialize(stdout, stderr, pstatus)
      @stdout = stdout.tap(&:rewind).read
      @stderr = stderr.tap(&:rewind).read
      @status = pstatus
    end
  end

  ##
  # @param [String] cmd
  #  A command to execute
  #
  # @return [Test::Cmd::Result]
  #  Returns an instance of {Test::Cmd::Result Test::Cmd::Result}
  def cmd(cmd)
    out = Tempfile.new("cmd-stdout").tap(&:unlink)
    err = Tempfile.new("cmd-stderr").tap(&:unlink)
    Process.wait spawn(cmd, {err:, out:})
    Result.new(out, err, $?)
  ensure
    out.close
    err.close
  end
end
