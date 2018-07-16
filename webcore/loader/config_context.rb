require_relative 'config.rb'

module Webcore
    class ConfigContext
        def initialize file
            @file = file
        end

        def load
            self.instance_eval(File.read(@file), @file)
        end

        def configure! &block
            config = ModuleConfiguration.new
            config.file = @file
            block.call(config)
            config
        end
    end
end