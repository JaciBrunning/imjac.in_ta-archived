require 'sinatra/base'
require 'builder'
require 'fileutils'
require 'utils'

JEKYLL_BUILD_FOLDER = File.join(web_root(), '_build/html')

class Main < Sinatra::Base
    set :public_folder, JEKYLL_BUILD_FOLDER

    get '/ta/?' do
        send_file File.join(settings.public_folder, 'ta/index.html')
    end

    # Usually this would be accessed from r.imjac.in, but in testing the domain name is different, so it's not
    # possible to change the uri for the resources, so we tunnel it here instead.
    get '/res/*' do
        resource = params['splat'].first
        if resource.nil? || resource.empty?
            status 404
        else
            file = File.join(File.join(web_root(), '_build/resources'), Utils.strippath(resource))
            if File.directory?(file) || !File.exists?(file)
                status 404
            else
                send_file file
            end 
        end
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

class JekyllBuilder < Builder
    clean do
        FileUtils.rm_r JEKYLL_BUILD_FOLDER if File.exists?(JEKYLL_BUILD_FOLDER)
    end

    build do
        `jekyll build -s #{File.join(web_root(), 'jekyll')} -d #{JEKYLL_BUILD_FOLDER}/ta`
    end
end

define_webcore_module :main, Main
define_virtual_server /.*/, :main, priority: 100
define_builder :jekyll, JekyllBuilder.new