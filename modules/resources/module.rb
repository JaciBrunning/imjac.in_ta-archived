require 'sinatra/base'
require 'builder'
require 'fileutils'

RES_BUILD_FOLDER = File.join(web_root(), '_build/resources')
CSS_BUILD_FOLDER = File.join(RES_BUILD_FOLDER, 'css')

class Resources < Sinatra::Base
    set :public_folder, RES_BUILD_FOLDER
end

class CSSBuilder < Builder
    clean do
        FileUtils.rm_r CSS_BUILD_FOLDER if File.exists?(CSS_BUILD_FOLDER)
    end

    build do
        FileUtils.mkdir_p CSS_BUILD_FOLDER
        `sass -I css/sass -I css/sass -t compressed #{File.join(web_root(), 'css/sass/milligram_jaci/milligram_jaci.sass')} #{File.join(CSS_BUILD_FOLDER, 'milligram_jaci.css')}` 
        `sass -I css/sass -I css/sass -t compressed #{File.join(web_root(), 'css/sass/blog/blog.scss')} #{File.join(CSS_BUILD_FOLDER, 'blog.css')}`
    end
end

define_webcore_module :resources, Resources
define_virtual_server /r\..*/, :resources
define_builder :css, CSSBuilder.new