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

    r = BufferResource.new(:"test.css", "https://cdnjs.cloudflare.com/ajax/libs/milligram/1.3.0/milligram.min.css")
    r.memcache = true
    services.cdn.register r

    q = StaticResource.new(:"test.js", "alert('Hello World');")
    q.memcache = true
    services.cdn.register q
end