require 'sinatra/base'
require 'builder'
require 'fileutils'
require 'utils'

JEKYLL_BUILD_FOLDER = File.join(web_root(), '_build/html')

class Main < Sinatra::Base
    set :public_folder, JEKYLL_BUILD_FOLDER
    register Extensions::Resources

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

class JekyllBuilder < Builder
    def clean
        FileUtils.rm_r JEKYLL_BUILD_FOLDER if File.exists?(JEKYLL_BUILD_FOLDER)
    end

    def build
        `jekyll build -s #{File.join(web_root(), 'jekyll')} -d #{JEKYLL_BUILD_FOLDER}/ta`
    end
end

define_webcore_module :main, Main
define_virtual_server /.*/, :main, priority: 100
Builders.register :jekyll, JekyllBuilder.new