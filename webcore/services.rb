require_relative 'cdn/cdnservice'
require_relative 'cache/memcacheservice'
require_relative 'webcore'

module Webcore
    class Services
        attr_reader :webcore
        attr_reader :cdn
        attr_reader :memcache
        # attr_reader :db

        def initialize webcore, id
            @webcore = webcore
            @cdn = CDNService.new
            @memcache = MemcacheService.new(id)
            # @db = DBService.new(ENV['WEBCORE_DB_URL'] || 'postgres://web:web@localhost/web')
        end
    end
end