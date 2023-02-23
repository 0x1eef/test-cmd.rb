module Test
end unless defined?(Test)

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

    ##
    # @param [Tempfile] stdout
    # @param [Tempfile] stderr
    # @return [Test::Cmd::Result]
    def initialize(stdout, stderr)
      @stdout = stdout.tap(&:rewind).read
      @stderr = stderr.tap(&:rewind).read
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
    Result.new(out, err)
  ensure
    out.close
    err.close
  end
end
