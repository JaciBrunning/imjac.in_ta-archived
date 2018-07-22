require_relative 'routing/domain_registry'
require_relative 'cron/registry'
require_relative 'resources/libs'

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