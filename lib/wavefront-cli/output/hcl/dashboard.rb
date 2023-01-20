# frozen_string_literal: true

require_relative 'base'
require_relative 'stdlib/string'
require_relative 'stdlib/array'

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
    #
    # Top-level fields
    #
    def hcl_fields
      %w[name description url sections parameter_details tags]
    end

    def khandle_sections
      'section'
    end

    # @param vals [Array] an array of objects
    # @param method [Symbol] a method which knows how to deal with one
    #   of the objects in vals
    # @return [String] HCL list of vals
    #
    def listmaker(vals, method)
      vals.each_with_object([]) { |v, a| a << send(method, v) }.to_hcl_list
    end

    def vhandle_sections(vals)
      vals.each_with_object([]) do |section, a|
        a << ("name = \"#{section[:name]}\"\n      row = " +
              handle_rows(section[:rows])).braced(4)
      end.to_hcl_list
    end

    def handle_rows(rows)
      rows.each_with_object([]) do |row, a|
        a << "chart = #{handle_charts(row[:charts])}".braced(8)
      end.to_hcl_list
    end

    def handle_charts(charts)
      listmaker(charts, :handle_chart)
    end

    def handle_chart(chart)
      fields = %w[units name description]

      lines = chart.each_with_object([]) do |(k, v), a|
        next unless fields.include?(k)

        a << format('%<key>s = %<value>s', key: k, value: quote_value(v))
      end

      lines << "source = #{handle_sources(chart[:sources])}"
      lines.to_hcl_obj(10)
    end

    def handle_sources(sources)
      listmaker(sources, :handle_source)
    end

    def handle_source(source)
      source.each_with_object([]) do |(k, v), a|
        next unless source_fields.include?(k)

        k = 'queryBuilderEnabled' if k == 'querybuilderEnabled'

        a << format('%<key>s = %<value>s',
                    key: k.to_snake,
                    value: quote_value(v))
      end.to_hcl_obj(14)
    end

    def source_fields
      %w[name query disabled scatterPlotSource querybuilderEnabled
         sourceDescription]
    end

    def qhandle_sections(val)
      val
    end

    def quote_value(val)
      val.gsub!(/\$/, '$$') if val.is_a?(String)
      super
    end
  end
end
