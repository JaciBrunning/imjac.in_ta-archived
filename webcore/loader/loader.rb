require_relative 'config_context'
require_relative '../module'
require_relative '../services'

module Webcore
    class Loader
        attr_accessor :search_paths

        def initialize search_paths
            @search_paths = search_paths.map { |path| File.expand_path(path) }
        end

        def discover
            configs = @search_paths.map do |path|
                Dir[File.join(path.gsub("\\", "/"), '**/*.webcore.rb')]
            end.flatten
            configs.each do |c|
                puts "[LOADER] Found module configuration: #{c}"
            end
            configs
        end

        def configure config_files
            ids = []
            config_files.map do |cfile|
                ctx = ConfigContext.new cfile
                config = ctx.load
                id = config.id
                unless ids.include? id
                    puts "[LOADER] Loaded Module Config: #{id} -> #{cfile}"
                    ids << id
                    config
                else
                    puts "[LOADER] * Duplicate Module ID Found: #{id}, ignoring..."
                    nil
                end
            end.reject(&:nil?)
        end

        def load_modules config_objs, webcore
            config_objs.map do |c|
                services = Services.new webcore, c.id
                mod = Module.new c, services
                webcore.modules[c.id] = mod
                mod.load
                puts "[LOADER] Loaded Module: #{mod.id}"
            end
        end

        def run! webcore
            cfiles = discover
            configs = configure cfiles
            load_modules configs, webcore
        end
    end
end