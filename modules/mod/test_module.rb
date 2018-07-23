require 'webcore/cdn/extension'
require 'webcore/db/authextension'
require 'sinatra/cookies'

class TestModule < WebcoreApp()
    register AuthExtension
    register ::Webcore::CDNExtension

    get "/?" do
        "Hello World"
    end

    get "/priviledged/?" do
        auth!
        "Hello #{@user.name}"
    end
end