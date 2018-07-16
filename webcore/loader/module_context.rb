module Webcore
    class ModuleContext
        attr_reader :module_config
        attr_reader :module_id

        def initialize module_config, webcore
            @module_config = module_config
            @module_id = @module_config.id
            @webcore = webcore
        end

        def load
            modulefile = File.dirname(@module_config.file) + "/" + @module_config.module
            self.instance_eval(File.read(modulefile), modulefile)
        end
    end
end