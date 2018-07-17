require 'webcore/base'
require 'webcore/extensions/memcache'

class TestModule < ::Webcore::Base
    register ::Webcore::Extensions::Memcache
    set :memcache_namespace, "TestModule"

    get "/" do
        cache "index" do
            puts "Fetching"
            "HELLO WORLD"
        end
    end

    get "/expire/?" do
        expire "index"
    end
end

@webcore.domains.register :test, /.*/, TestModule.new
