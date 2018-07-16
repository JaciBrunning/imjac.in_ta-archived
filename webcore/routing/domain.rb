module Webcore
    class Domain
        attr_reader :priority

        def initialize regex, server, priority
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