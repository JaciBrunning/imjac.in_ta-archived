require 'webcore/cache/memcache'

class TestModule < WebcoreApp()
    register ::Webcore::Extensions::Memcache
    set :memcache_namespace, "TestModule"

    get "/" do
        cache "index" do
            puts "Fetching"
            webcore_module.id.to_s
        end
    end

    get "/expire/?" do
        expire "index"
    end
end