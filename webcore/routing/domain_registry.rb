require_relative 'domain.rb'

module Webcore
    class DomainRegistry
        def initialize
            @domains = []
        end

        def register id, domain_regex, server, options={}
            options = { priority: 50 }.merge(options)
            register_domain Domain.new(id, domain_regex, server, options[:priority])
        end

        def register_domain domain
            @domains << domain
            @domains.sort_by! { |d| d.priority }
        end

        def query domain_str
            @domains.first { |d| d.matches?(domain_str) }
        end

        def [] id
            @domains.first { |x| x.id == id }
        end

        def get
            @domains
        end
    end
end