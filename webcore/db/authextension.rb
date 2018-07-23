require 'sinatra/cookies'
require_relative 'auth'

module Webcore
    module AuthExtension
        module Helpers
            def redirect_login! refer
                portstr = ""
                if request.port != 80 && request.port != 443
                    portstr = ":#{request.port}"
                end
                # TODO: Escape
                redirect "http://auth.#{services.webcore.rootdomain}#{portstr}/login?refer=#{refer}"
            end

            def auth?
                !@user.nil?
            end

            def auth!
                redirect_login! request.url unless auth?
            end

            def auth_su?
                !@user.nil? && @user.superuser
            end

            def auth_su!
                redirect_login! request.url unless auth_su?
            end
        end

        def self.registered app
            app.enable :sessions
            app.helpers Sinatra::Cookies
            app.helpers ::Webcore::AuthExtension::Helpers
            app.set :cookie_options, domain: ".#{app.services.webcore.rootdomain}"

            app.before do
                tok = Security.decrypt(cookies[:webcore_token], app.services.webcore.sso_secret)
                @auth_token = Auth.login_token(tok)
                @user = @auth_token.is_a?(Symbol) ? nil : @auth_token.user

                cookies.delete :webcore_token if @user.nil? # Cleanup if the login failed
            end
        end
    end
end