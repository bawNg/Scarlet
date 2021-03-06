# Scarlet - an IRC bot which is slowly becoming an automated assistant framework
# Goal: Make it adapter based and not limited to a protocol.
#----------------------------------------------------------------
# uses mustache for templating and active_support
# errors - light_red, info - light_blue, success - light_green
require 'mustache'

class Hash # instead of hash[:key][:key], hash.key.key
  def method_missing(method, *params)
    # if it ends with = it's a setter, so set the value - SLOPPY CODE, CLEAN!
    return self[method.to_s.chomp('=').to_sym] = params[0] if method.to_s.end_with? '='
    # if it contains that key, return the value
    return self[method.to_s] if self.keys.collect {|key| key}.include?(method.to_s)
    return self[method.to_sym] if self.keys.collect {|key| key}.include?(method.to_sym)
    #return nil # if it doesn't exist, return nil. Do not error
    super
  end
end

module Scarlet; end # Stub class so we can safely load in files
base_path = File.expand_path File.dirname(__FILE__)
Modules.load_models base_path
Modules.load_libs base_path

module Scarlet
  @config = {}
  @@servers = {}
  class << self
    attr_accessor :config

    def loaded
      $config[:irc_bot] = YAML.load_file("#{File.expand_path File.dirname(__FILE__)}/config.yml").symbolize_keys!
      # create servers
      $config.irc_bot.servers.each do |name, cfg|
        @@servers[name] = Server.new cfg
      end
      # for now for safety delete the servers list after it gets loaded
      $config.irc_bot.delete :servers
      # connect servers
      @@servers.values.each do |server|
        server.connection = EventMachine::connect(server.config.address, server.config.port, Connection, server)
      end
      puts 'Scarlet process has started.'.green
    end

    def unload
      @@servers.values.each do |server|
        server.disconnect
        server.log.close_all
        server.scheduler.remove_all
      end
    end

    def load_commands root
        Dir["#{root}/commands/**/*.rb"].each {|path| load path }
    end

    # DSL delegator to Command. (Scarlet.hear is more expressive than Command.hear)
    def hear regex, clearance=nil, &block
      Command.hear regex, clearance, &block
    end
  end
end

# load custom commands - TODO: move it inside def load_commands 
# (which is unused at the moment) and execute it inside def loaded.
Dir["#{base_path}/commands/**/*.rb"].each {|path| 
  load path 
  Scarlet::Command.parse_help path
}