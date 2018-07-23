require_relative 'app'

module Webcore
    class Module
        attr_reader :id
        attr_reader :config
        attr_reader :services

        def initialize config, services
            @config = config
            @id = @config.id

            @services = services
        end

        def WebcoreApp
            ::Webcore::App::create_app self
        end

        def register_domain server
            @services.webcore.domains.register(@id, @config.host, server, @config.priority)
        end

        def module_file
            File.dirname(@config.file) + "/" + @config.module
        end

        def load
            mfile = module_file
            self.instance_eval(File.read(mfile), mfile)
        end
    end
end