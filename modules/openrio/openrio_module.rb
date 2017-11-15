require 'sinatra/base'
require 'base64'
require 'zlib'
require 'stringio'
require 'json'

class OpenRIOModule < Sinatra::Base
    get "/gradlerio/recommended/?" do
        content_type 'application/json'
        send_file "#{File.dirname(__FILE__)}/recommended_versions.json"
    end

    post "/gradlerio/telemetry/report" do
        json = JSON.parse(Zlib::GzipReader.new(StringIO.new(Base64.decode64(request.body.read))).read)
        OpenRIO::DB::report(json)
        'SUCCESS'
    end
end

define_webcore_module :openrio, OpenRIOModule
define_virtual_server /openrio.*/, :openrio