require 'securerandom'

require_relative 'routing/domain_registry'
require_relative 'cron/registry'

module Webcore
    class Webcore
        attr_reader :modules
        attr_reader :root
        attr_reader :rootdomain
        attr_reader :startup_time
        attr_reader :domains
        attr_reader :sso_secret

        def initialize root, rootdomain
            @root = root
            @modules = {}
            @rootdomain = rootdomain
            @startup_time = DateTime.now
            @domains = DomainRegistry.new
            @sso_secret = SecureRandom.hex(64)
        end
    end
end