module WavefrontCli
  class Exception
    class CredentialError < RuntimeError; end
    class FileNotFound < IOError; end
    class InsufficientData < RuntimeError; end
    class InvalidInput < RuntimeError; end
    class SystemError < RuntimeError; end
    class UnhandledCommand < RuntimeError; end
    class UnparseableInput < RuntimeError; end
    class UnparseableResponse < RuntimeError; end
    class UnsupportedFileFormat < RuntimeError; end
    class UnsupportedOperation < RuntimeError; end
    class UnsupportedOutput < RuntimeError; end
  end
end
