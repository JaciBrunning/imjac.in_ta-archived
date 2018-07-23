require 'webcore/cdn/extension'
require 'webcore/db/auth'
require 'sinatra/cookies'

# Single Sign-On Module
class SSOModule < WebcoreApp()
    enable :sessions
    helpers Sinatra::Cookies
    set :cookie_options, domain: ".#{services.webcore.rootdomain}"

    register ::Webcore::CDNExtension
    set :root, File.dirname(__FILE__)

    def write_token tok
        cookies[:webcore_token] = Security.encrypt(tok, services.webcore.sso_secret)
    end

    def read_token
        Security.decrypt(cookies[:webcore_token], services.webcore.sso_secret)
    end

    def delete_token
        cookies.delete :webcore_token
    end

    get "/" do
        token = Auth::login_token(read_token)
        halt token.to_s if token.is_a?(Symbol)
    end

    get "/login/?" do
        @title = "Login"
        session[:refer] = params[:refer]
        redirect "/register" if Auth::User.count == 0
        erb :login
    end

    get "/logout/?" do
        Auth::deauth_single(read_token)
        delete_token
        redirect "/login"
    end

    get "/register/?" do
        @title = "Register"
        erb :register
    end

    post "/register/?" do
        Auth::create params[:username], params[:email], params[:name], params[:password], (Auth::User.count == 0)
        redirect "/login"
    end

    post "/login" do
        login = params[:login]
        password = params[:password]

        token = Auth::login_password(login, password)
        redirect "/login?error=#{token}" if token.is_a?(Symbol)
        write_token token.id.to_s
        if session[:refer]
            url = session[:refer]
            session.delete :refer
            redirect url
        else
            redirect "/"
        end
    end
end