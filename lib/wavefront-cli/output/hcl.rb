# frozen_string_literal: true

require_relative 'base'

module WavefrontOutput
  #
  # Display objects in an HCL-compatible way, for use with the
  # Wavefront Terraform provider. We farm everything out, as
  # different resource types need various amounts of massaging. Args
  # are passed through to the child class.
  #
  class Hcl < Base; end
end
