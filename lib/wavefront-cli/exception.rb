module WavefrontCli
  class Exception
    class UnhandledCommand < RuntimeError; end
    class UnparseableInput < RuntimeError; end
    class UnsupportedOutput < RuntimeError; end
    class UnsupportedFileFormat < RuntimeError; end
    class CredentialError < RuntimeError; end
    class InsufficientData < RuntimeError; end
    class FileNotFound < IOError; end
    class SystemError < RuntimeError; end
  end
end
