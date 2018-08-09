module WavefrontCli
  class Exception
    class UnhandledCommand < RuntimeError; end
    class UnsupportedOutput < RuntimeError; end
    class CredentialError < RuntimeError; end
    class InsufficientData < RuntimeError; end
  end
end
