require 'db/login'

module Extensions
    module Auth
        module Helpers
            def auth?
                !@user.nil?
            end

            def auth_su?
                !@user.nil? && @user.superuser
            end

            def auth!
                redirect "/login" unless @user
            end

            def auth_su!
                redirect "/login" unless @user && @user.superuser
            end
        end

        def self.registered(app)
            app.enable :sessions

            app.helpers Extensions::Auth::Helpers

            app.before do
                @token = Database::Login.login_token session[:token]
                @user = @token.is_a?(Symbol) ? nil : @token.user 

                session[:token] = nil if @user.nil?
            end

            app.post '/login' do
                login = params[:login]
                password = params[:password]

                token = Database::Login.login_password(login, password)
                redirect "/login?error=#{token}" if token.is_a?(Symbol)
                session[:token] = token.tok_string
                redirect "/"
            end

            app.get '/logout' do
                Database::Login.deauth_single(session[:token])
                session[:token] = nil
                redirect "/login"
            end
        end
    end
end