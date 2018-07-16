module Webcore
    class Middleware
        def initialize app, registry
            @app = app
            @registry = registry
        end

        def call(env)
            domain_str = env["HTTP_HOST"][/^[^:]+/]
            domain = @registry.query(domain_str)
            unless domain.nil?
                domain.handle env
            else
                @app.call(env)
            end
        end
    end
end