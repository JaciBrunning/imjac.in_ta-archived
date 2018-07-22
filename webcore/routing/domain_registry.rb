require_relative 'domain.rb'

module Webcore
    class DomainRegistry
        def initialize
            @domains = []
        end

        def register id, domain_regex, server, priority
            register_domain Domain.new(id, domain_regex, server, priority)
        end

        def register_domain domain
            @domains << domain
            @domains.sort_by! { |d| d.priority }
        end

        def query domain_str
            @domains.find { |d| d.matches?(domain_str) }
        end

        def [] id
            @domains.find { |x| x.id == id }
        end

        def get
            @domains
        end
    end
end