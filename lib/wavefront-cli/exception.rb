module WavefrontCli
  #
  # CLI-specific exceptions. These should generally be caught in the
  # controller.
  #
  class Exception
    class CredentialError < RuntimeError; end
    class MandatoryValue < RuntimeError; end
    class ConfigFileNotFound < IOError; end
    class FileNotFound < IOError; end
    class ImpossibleSearch < RuntimeError; end
    class InsufficientData < RuntimeError; end
    class InvalidInput < RuntimeError; end
    class InvalidQuery < RuntimeError; end
    class InvalidValue < RuntimeError; end
    class ProfileExists < RuntimeError; end
    class ProfileNotFound < RuntimeError; end
    class SystemError < RuntimeError; end
    class UnhandledCommand < RuntimeError; end
    class UnparseableInput < RuntimeError; end
    class UnparseableResponse < RuntimeError; end
    class UnparseableSearchPattern < RuntimeError; end
    class UnsupportedFileFormat < RuntimeError; end
    class UnsupportedNoop < RuntimeError; end
    class UnsupportedOperation < RuntimeError; end
    class UnsupportedOutput < RuntimeError; end
    class UserGroupNotFound < RuntimeError; end
  end
end
