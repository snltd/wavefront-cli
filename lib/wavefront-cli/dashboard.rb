require 'pathname'
require 'json'
require 'yaml'
require 'wavefront-sdk/dashboard'
require_relative './base'

class WavefrontCli::Dashboard < WavefrontCli::Base
  attr_accessor :wfd

  include WavefrontCli::Constants

  def run
    @wfd = Wavefront::Dashboard.new(
      options[:token], options[:endpoint], options[:debug],
      noop: options[:noop], verbose: options[:verbose]
    )

    list_dashboards if options[:list]
    export_dash if options[:export]
    create_dash if options[:create]
    delete_dash if options[:delete]
    undelete_dash if options[:undelete]
    history_dash if options[:history]
    clone_dash if options[:clone]
    import_dash if options[:import]
  end

  def import_dash
    wfd.import(load_file(options[:'<file>']).to_json, options[:force])
    puts 'Dashboard imported' unless options[:noop]
  rescue RestClient::BadRequest
    raise '400 error: dashboard probably exists, and force not used'
  end

  def clone_dash
    wfd.clone(options[:'<source_id>'], options[:'<new_id>'],
              options[:'<new_name>'], options[:version])
    puts 'Dashboard cloned' unless options[:noop]
  rescue RestClient::BadRequest
    raise '400 error: either target exists or source does not'
  end

  def history_dash
    begin
      resp = wfd.history(options[:'<dashboard_id>'],
                         options[:start] || 100,
                         options[:limit] || nil)
    rescue RestClient::ResourceNotFound
      raise 'Dashboard does not exist'
    end

    display_resp(resp, :human_history)
  end

  def undelete_dash
    wfd.undelete(options[:'<dashboard_id>'])
    puts 'dashboard undeleted' unless options[:noop]
  rescue RestClient::ResourceNotFound
    raise 'Dashboard does not exist'
  end

  def delete_dash
    wfd.delete(options[:'<dashboard_id>'])
    puts 'dashboard deleted' unless options[:noop]
  rescue RestClient::ResourceNotFound
    raise 'Dashboard does not exist'
  end

  def create_dash
    wfd.create(options[:'<dashboard_id>'], options[:'<name>'])
    puts 'dashboard created' unless options[:noop]
  rescue RestClient::BadRequest
    raise '400 error: dashboard probably exists'
  end

  def export_dash
    resp = wfd.export(options[:'<dashboard_id>'], options[:version] || nil)
    options[:dashformat] = :json if options[:dashformat] == :human
    display_resp(resp)
  end

  def list_dashboards
    resp = wfd.list({ private: options[:privatetag],
                      shared: options[:sharedtag] })
    display_resp(resp, :human_list)
  end

  def display_resp(resp, human_method = nil)
    return if options[:noop]

    case options[:dashformat].to_sym
    when :json
      if resp.is_a?(String)
        puts resp
      else
        puts resp.to_json
      end
    when :yaml
      puts resp.to_yaml
    when :human
      unless human_method
        raise 'human output format is not supported by this subcommand'
      end

      send(human_method, JSON.parse(resp))
    else
      raise 'unsupported output format'
    end
  end

  def human_history(resp)
    resp.each do |rev|
      puts format('%-4s%s (%s)', rev['version'],
                  Time.at(rev['update_time'].to_i / 1000),
                  rev['update_user'])

      next unless rev['change_description']
      rev['change_description'].each { |desc| puts '      ' + desc }
    end
  end

  def human_list(resp)
    #
    # Simply list the dashboards we have. If the user wants more
    #
    max_id_width = resp.map { |s| s['url'].size }.max

    puts format("%-#{max_id_width + 1}s%s", 'ID', 'NAME')

    resp.each do |dash|
      next if !options[:all] && dash['isTrash']
      line = format("%-#{max_id_width + 1}s%s", dash['url'], dash['name'])
      line.<< ' (in trash)' if dash['isTrash']
      puts line
    end
  end
end
