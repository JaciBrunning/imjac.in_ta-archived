require 'webcore/cdn/extension'

class TestModule < WebcoreApp()
    register ::Webcore::CDNExtension

    get "/" do
        "Hello World"
    end

    r = BufferResource.new(:"test.css", "https://cdnjs.cloudflare.com/ajax/libs/milligram/1.3.0/milligram.min.css")
    r.memcache = true
    services.cdn.register r

    q = StaticResource.new(:"test.js", "alert('Hello World');")
    q.memcache = true
    services.cdn.register q
end