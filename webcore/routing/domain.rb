module Webcore
    class Domain
        attr_reader :priority
        attr_reader :id
        attr_reader :server

        def initialize id, regex, server, priority
            @id = id
            @regex = regex
            @server = server
            @priority = priority
        end

        def matches? domain
            @regex =~ domain
        end

        def handle env
            @server.call(env)
        end
    end
end