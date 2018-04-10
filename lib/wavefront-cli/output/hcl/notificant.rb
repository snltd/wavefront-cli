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

    def vhandle_template(v)
      v.gsub(/\s*\n/, '')
    end

    def resource_name
      'alert_target'
    end

    def khandle_title
      'name'
    end

    def khandle_customHttpHeaders
      'custom_headers'
    end
  end
end
