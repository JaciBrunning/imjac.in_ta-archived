require 'webcore/cdn/extension'
require 'webcore/db/authextension'

class TestModule < WebcoreApp()
    register AuthExtension
    register CDNExtension

    get "/?" do
        "Hello World"
    end

    get "/priviledged/?" do
        auth!
        "Hello #{@user.name}"
    end
end