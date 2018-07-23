require 'dalli'

module Webcore
    class MemcacheService
        def initialize namespace, addr="127.0.0.1:11211", options={}
            @namespace = namespace.to_s
            @addr = addr
            @options = { compress: true, expires_in: 1800, namespace: "WC" }.merge(options)
        end

        def client
            @client ||= Dalli::Client.new(@addr, @options)
        end

        def cache key, ttl=nil, options={}, &block
            begin
                key = options[:global] ? key : "#{@namespace}:#{key}"
                client.fetch(key, ttl, options, &block)
            rescue Dalli::RingError
                puts "!! Memcache service not ready"
                block.call
            end
        end

        def cache_if should_cache, key, ttl=nil, options={}, &block
            if should_cache
                cache key, ttl, options, &block
            else
                block.call
            end
        end

        def expire key, options={}
            begin
                key = options[:global] ? key : "#{@namespace}:#{key}"
                client.delete key
                true
            rescue Dalli::RingError
                puts "!! Memcache service not ready"
                false
            end
        end
    end
end