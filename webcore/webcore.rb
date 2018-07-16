require_relative 'routing/domain_registry'
# TODO: Subinstances for modules? Allows disabling while active.
module Webcore
    class Webcore
        attr_reader :modules
        attr_reader :domains
        attr_reader :root

        def initialize root
            @root = root
            @modules = {}
            @domains = DomainRegistry.new
        end
    end
end