require 'sinatra/base'
# require 'extensions/resources'
require 'utils'
require 'libs'
require 'pathname'

DEV_WWW_FOLDER = File.join(@webcore.root, '_public/dev')
FileUtils.mkdir_p DEV_WWW_FOLDER

class Dev < Sinatra::Base
    set :public_folder, DEV_WWW_FOLDER
    # register Extensions::Resources

    get "/ta/?" do
        redirect "/"
    end

    get '*' do |path|
        file = File.join(settings.public_folder, Utils.strippath(path))
        if File.exist?(file)
            if File.directory?(file)
                @directory = file
                @path = Utils.strippath(path)
                erb :dirlist
            else
                send_file file
            end
        else
            not_found
        end
    end

    not_found do
        status 404
        "Error 404: Resource not found"
    end
end

@webcore.domains.register /.*/, Dev.new