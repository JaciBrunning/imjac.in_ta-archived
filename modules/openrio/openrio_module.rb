require 'sinatra/base'

class OpenRIOModule < Sinatra::Base
    get "/gradlerio/recommended/?" do
        content_type 'application/json'
        send_file "#{File.dirname(__FILE__)}/recommended_versions.json"
    end
end

define_webcore_module :openrio, OpenRIOModule
define_virtual_server /openrio.*/, :openrio