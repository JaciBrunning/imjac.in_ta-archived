require 'webcore/cdn/extension'
require 'sinatra/cookies'

class TestModule < WebcoreApp()
    helpers Sinatra::Cookies
    enable :sessions
    # set :session_secret, services.webcore.session_secret

    register ::Webcore::CDNExtension

    get "/?" do
        "Hello World"
    end

    get "/readsession" do
        Security.decrypt(cookies[:test], services.webcore.sso_secret)
    end
end