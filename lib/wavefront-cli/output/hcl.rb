require_relative 'base'

module WavefrontOutput
  #
  # Display objects in an HCL-compatible way, for use with the
  # Wavefront Terraform provider. We farm everything out, as
  # different resource types need various amounts of massaging. Args
  # are passed through to the child class.
  #
  class Hcl < Base
    def run
      require_relative File.join('hcl', options[:class])
      oclass = Object.const_get(format('WavefrontHclOutput::%s',
                              options[:class].to_s.capitalize))
      oclass.new(resp, options).run
    rescue LoadError
      abort "no HCL output for #{options[:class]}."
    end
  end
end
