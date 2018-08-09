require_relative 'base'

module WavefrontHclOutput
  #
  # Munge notificant output into something compatible with the
  # Wavefront Terraform provider
  #
  class Notificant < Base
    def hcl_fields
      %w[title description triggers template method recipient emailSubject
         contentType customHttpHeaders]
    end

    def vhandle_template(val)
      val.gsub(/\s*\n/, '')
    end

    def resource_name
      'alert_target'
    end

    def khandle_title
      'name'
    end

    # rubocop:disable Naming/MethodName
    def khandle_customHttpHeaders
      'custom_headers'
    end
    # rubocop:enable Naming/MethodName
  end
end
