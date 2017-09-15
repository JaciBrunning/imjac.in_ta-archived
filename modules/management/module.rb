require 'sinatra/base'

class Management < Sinatra::Base

end

define_webcore_module :management, Management
define_virtual_server /manage.*/, :management