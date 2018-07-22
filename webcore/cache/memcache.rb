require 'dalli'

module Webcore
module Extensions
    module Memcache
        module Helpers
            def cache key, ttl=nil, options={}, &block
                begin
                    cacher.fetch(key, ttl, options, &block)
                rescue Dalli::RingError
                    puts "!! Dalli not present!"
                    block.call
                end
            end

            def expire key
                begin
                    cacher.delete key
                    true
                rescue Dalli::RingError
                    puts "!! Dalli not present!"
                    false
                end
            end

            def cacher
                settings.memcache_client ||= Dalli::Client.new(settings.memcache_addr, { namespace: settings.memcache_namespace }.merge(settings.memcache_options))
            end
        end

        def self.registered(app)
            app.helpers Memcache::Helpers
            app.set :memcache_client, nil
            app.set :memcache_addr, "127.0.0.1:11211"
            app.set :memcache_namespace, nil
            app.set :memcache_options, { compress: true, expires_in: 1800 }
        end
    end
end
end