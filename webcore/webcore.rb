require_relative 'routing/domain_registry'
require_relative 'cron/registry'
# TODO: Subinstances for modules? Allows disabling while active.
module Webcore
    class Webcore
        attr_reader :modules
        attr_reader :domains
        attr_reader :cron
        attr_reader :root

        def initialize root
            @root = root
            @modules = {}
            @domains = DomainRegistry.new
            @cron = CronRegistry.new
        end
    end
end