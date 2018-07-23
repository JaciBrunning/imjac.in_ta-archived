require 'webcore/cdn/extension'

class TestModule < WebcoreApp()
    register ::Webcore::CDNExtension

    get "/?" do
        "Hello World"
    end
end