module WavefrontCli
  class Exception
    class UnhandledCommand < RuntimeError; end
    class UnsupportedOutput < RuntimeError; end
  end
end
