module WavefrontOutput
  #
  # To display in an output, call the #run method. This hands off
  # control to #_run in the child classes.
  #
  class Base
    attr_reader :resp, :options

    def initialize(resp = {}, options = {})
      @resp = resp
      @options = options
    end

    # We used to call #run directly, but now we use this wrapper to
    # make it easier to test the #_run methods.
    #
    def run
      puts _run
    end

    # Some output formats (HCL, Wavefront), only make sense for
    # certain subcommands. To implement those, we make a directory
    # in here containing a class file for each supported output. To
    # delegate control to one of those classes, have your #run
    # method call this
    #
    def delegate_run(klass)
      require_relative File.join(klass.downcase, options[:class])

      oclass = Object.const_get(format('Wavefront%sOutput::%s',
                              klass.downcase.capitalize,
                              options[:class].to_s.capitalize))
      oclass.new(resp, options).run
    rescue LoadError
      abort format("The '%s' command does not support %s format output.",
                   options[:class], klass)
    end
  end
end
