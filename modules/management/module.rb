require 'sinatra/base'

class Management < Sinatra::Base

    get "/rebuild/:builder/?" do
        get_all_builders()[params[:builder].to_sym].run
        "Done"
    end

end

define_webcore_module :management, Management
define_virtual_server /manage.*/, :management