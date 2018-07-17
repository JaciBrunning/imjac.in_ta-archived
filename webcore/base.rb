require 'sinatra/base'
require 'sinatra/reloader'

module Webcore
    class Base < Sinatra::Base
        configure :development do
            puts "WARNING: DEV MODE!"
        end
    end
end
