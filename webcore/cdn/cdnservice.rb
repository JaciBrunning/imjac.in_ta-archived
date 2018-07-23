require_relative 'resource'

module Webcore
    class CDNService
        def initialize
            @resources = {}
        end

        def [] sym
            @resources[sym]
        end

        def register resource
            @resources[resource.id] = resource
        end
    end
end