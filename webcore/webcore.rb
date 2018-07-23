require_relative 'routing/domain_registry'
require_relative 'cron/registry'

module Webcore
    class Webcore
        attr_reader :modules
        attr_reader :domains
        attr_reader :root
        attr_reader :startup_time

        def initialize root
            @root = root
            @modules = {}
            @startup_time = DateTime.now
            @domains = DomainRegistry.new
        end
    end
end