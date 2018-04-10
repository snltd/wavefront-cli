require_relative 'base'

module WavefrontHclOutput
  #
  # Define alerts which can be understood by the Wavefront Terraform
  # provider.
  #
  class Alert < Base
    def hcl_fields
      %w[name target condition additional_information display_expression
         minutes resolve_after_minutes severity tags]
    end
  end
end
