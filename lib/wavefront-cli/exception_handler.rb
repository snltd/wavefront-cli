# frozen_string_literal: true

require 'faraday'

module WavefrontCli
  #
  # Handle fatal errors.
  #
  module ExceptionMixins
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def exception_handler(exception)
      case exception
      when WavefrontCli::Exception::UnhandledCommand
        abort 'Fatal error. Unsupported command. Please open a Github issue.'
      when WavefrontCli::Exception::InvalidInput
        abort "Invalid input. #{exception.message}"
      when Interrupt
        abort "\nOperation aborted at user request."
      when WavefrontCli::Exception::ConfigFileNotFound
        abort "Configuration file #{exception}' not found."
      when WavefrontCli::Exception::CredentialError,
           Wavefront::Exception::CredentialError
        handle_missing_credentials(exception)
      when WavefrontCli::Exception::MandatoryValue
        abort 'A value must be supplied.'
      when Wavefront::Exception::NetworkTimeout
        abort 'Connection timed out.'
      when Wavefront::Exception::InvalidPermission
        abort "'#{exception}' is not a valid Wavefront permission."
      when Wavefront::Exception::InvalidTimestamp
        abort "'#{exception}' is not a parseable time."
      when Wavefront::Exception::InvalidUserGroupId
        abort "'#{exception}' is not a valid user group ID."
      when Wavefront::Exception::InvalidAccountId
        abort "'#{exception}' is not a valid system or user account ID."
      when Wavefront::Exception::InvalidAwsExternalId
        abort "'#{exception}' is not a valid AWS external ID."
      when Wavefront::Exception::InvalidRoleId
        abort "'#{exception}' is not a valid role ID."
      when Wavefront::Exception::InvalidApiTokenId
        abort "'#{exception}' is not a valid API token ID."
      when Wavefront::Exception::InvalidIngestionPolicyId
        abort "'#{exception}' is not a valid ingestion policy ID."
      when Wavefront::Exception::InvalidVersion
        abort "'#{exception}' is not a valid version."
      when WavefrontCli::Exception::InvalidValue
        abort "Invalid value for #{exception}."
      when WavefrontCli::Exception::ProfileExists
        abort "Profile '#{exception}' already exists."
      when WavefrontCli::Exception::ProfileNotFound
        abort "Profile '#{exception}' not found."
      when WavefrontCli::Exception::FileNotFound
        abort 'File not found.'
      when WavefrontCli::Exception::InsufficientData
        abort "Insufficient data. #{exception.message}"
      when WavefrontCli::Exception::InvalidQuery
        abort "Invalid query. API message: '#{exception.message}'."
      when WavefrontCli::Exception::SystemError
        abort "Host system error. #{exception.message}"
      when WavefrontCli::Exception::UnparseableInput
        abort "Cannot parse input. #{exception.message}"
      when WavefrontCli::Exception::UnparseableSearchPattern
        abort 'Searches require a key, a value, and a match operator.'
      when WavefrontCli::Exception::UnsupportedFileFormat
        abort 'Unsupported file format.'
      when WavefrontCli::Exception::UnsupportedOperation
        abort "Unsupported operation.\n#{exception.message}"
      when WavefrontCli::Exception::UnsupportedOutput
        abort exception.message
      when WavefrontCli::Exception::UnsupportedNoop
        abort 'Multiple API call operations cannot be performed as no-ops.'
      when WavefrontCli::Exception::UserGroupNotFound
        abort "Cannot find user group '#{exception.message}'."
      when Wavefront::Exception::UnsupportedWriter
        abort "Unsupported writer '#{exception.message}'."
      when WavefrontCli::Exception::UserError
        abort "User error: #{exception.message}."
      when WavefrontCli::Exception::ImpossibleSearch
        abort 'Search on non-existent key. Please use a top-level field.'
      when Wavefront::Exception::InvalidSamplingValue
        abort 'Sampling rates must be between 0 and 0.05.'
      when Faraday::ConnectionFailed
        abort 'Error connecting to remote host.'
      else
        warn "general error: #{exception}"
        backtrace_message(exception)
        abort
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
  end
end
