require_relative 'base'

module WavefrontHclOutput
  #
  # This is a rather kludgy class which generates HCL output
  # suitable for the Wavefront Terraform provider. It has to work
  # round a number of inconsistencies and omissions in said
  # provider, and will have to change as the provider improves.
  #
  # It works, manually, down the hierarchy described
  # in https://github.com/spaceapegames/terraform-provider-wavefront/blob/master/wavefront/resource_dashboard.go
  #
  class Dashboard < Base

    # Top-level fields
    #
    def hcl_fields
      %w[name description url sections parameter_details tags]
    end

    def khandle_sections
      'section'
    end

    # @param vals [Array] an array of objects
    # @param fn [Symbol] a method which knows how to deal with one
    #   of the objects in vals
    # @return [String] HCL list of vals
    #
    def listmaker(vals, fn)
      vals.each_with_object([]) { |v, a| a.<< send(fn, v) }.to_hcl_list
    end

    def vhandle_sections(v)
      v.each_with_object([]) do |section, a|
        a.<< ("name = \"#{section[:name]}\"\n      row = " +
              handle_rows(section[:rows])).braced(4)
      end.to_hcl_list
    end

    def handle_rows(rows)
      rows.each_with_object([]) do |row, a|
        a.<< ("chart = " + handle_charts(row[:charts]).to_s).braced(8)
      end.to_hcl_list
    end

    def handle_charts(charts)
      listmaker(charts, :handle_chart)
    end

    def handle_chart(chart)
      fields = %w[units name description]

      lines = chart.each_with_object([]) do |(k, v), a|
        a.<< format('%s = %s', k, quote_value(v)) if fields.include?(k)
      end

      lines.<< "source = #{handle_sources(chart[:sources])}"
      lines.to_hcl_obj(10)
    end

    def handle_sources(sources)
      listmaker(sources, :handle_source)
    end

    def handle_source(source)
      fields = %w[name query disabled scatterPlotSource querybuilderEnabled
                  sourceDescription]

      source.each_with_object([]) do |(k, v), a|
        if fields.include?(k)
          k = 'queryBuilderEnabled' if k == 'querybuilderEnabled'
          a.<< format('%s = %s', k.to_snake, quote_value(v))
        end
      end.to_hcl_obj(14)
    end

    def qhandle_sections(v)
      v
    end

    def quote_value(v)
      v.gsub!(/\$/, '$$') if v.is_a?(String)
      super
    end
  end
end

class String
  def braced(indent = 0)
    pad = ' ' * indent
    "\n#{pad}{#{self}\n#{pad}}"
  end
end

class Array
  #
  # Turn an array into a string which represents an HCL list
  # @return [String]
  #
  def to_hcl_list
    '[' + self.join(',') + ']'
  end

  # Turn an array into a string which represents an HCL object
  # @return [String]
  #
  def to_hcl_obj(indent = 0)
    outpad = ' ' * indent
    inpad = ' ' * (indent + 2)

    "\n#{outpad}{\n#{inpad}" + self.join("\n#{inpad}") + "\n#{outpad}}"
  end
end
