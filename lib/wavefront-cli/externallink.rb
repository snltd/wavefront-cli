require_relative 'base'

module WavefrontCli
  #
  # CLI coverage for the v2 'externallink' API.
  #
  class ExternalLink < WavefrontCli::Base
    def validator_method
      :wf_link_id?
    end

    def validator_exception
      Wavefront::Exception::InvalidExternalLinkId
    end

    def do_create
      body = { name:        options[:'<name>'],
               template:    options[:'<template>'],
               description: options[:'<description>'] }

      wf.create(body)
    end
  end
end
