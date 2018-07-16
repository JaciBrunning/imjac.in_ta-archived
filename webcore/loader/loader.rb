require_relative 'config_context.rb'
require_relative 'module_context.rb'

module Webcore
    class Loader
        attr_accessor :search_paths

        def initialize search_paths
            @search_paths = search_paths
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
            config_files.map do |cfile|
                # Eval is dangerous, but for a config file in a controlled environment it's fine.
                ctx = ConfigContext.new cfile
                config = ctx.load
                config
            end
        end

        def contextualize config_objs, webcore
            config_objs.map do |c|
                ctx = ModuleContext.new c, webcore
                webcore.modules[c.id] = ctx
                ctx
            end
        end

        def load_contexts ctxs
            ctxs.each do |ctx|
                ctx.load
            end
        end

        def run! webcore
            cfiles = discover
            configs = configure cfiles
            ctxs = contextualize configs, webcore
            load_contexts ctxs
        end
    end
end