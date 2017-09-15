require 'sinatra/base'

class Main < Sinatra::Base
    set :public_folder, File.dirname(__FILE__) + '/html'

    get '/ta/?' do
        send_file File.join(settings.public_folder, 'ta/index.html')
    end

    get '/' do
        redirect '/ta'
    end

    not_found do
        status 404
        body File.read(File.join(settings.public_folder, 'ta/404/index.html'))
    end

    get '/*' do
        composite_url = File.join(request.path_info, 'index.html')
        composite_file = File.join(settings.public_folder, composite_url)

        if File.exists?(composite_file)
            send_file composite_file
        else
            status 404
        end
    end
end

define_webcore_module :main, Main
define_virtual_server /.*/, :main, priority: 100