require 'builder'
require 'fileutils'
require 'utils'

RES_BUILD_FOLDER = File.join(web_root(), '_build/resources')
CSS_BUILD_FOLDER = File.join(RES_BUILD_FOLDER, 'css')

# TODO: Switch this over to a minified version for prod
JS_FOLDER = File.join(web_root(), 'js')

module Extensions
    module Resources
        def self.registered app
            app.get '/res/*' do
                cache_control :public, max_age: 60
                
                resource = params['splat'].first
                if resource.nil? || resource.empty?
                    status 404
                else
                    file = File.join(RES_BUILD_FOLDER, Utils.strippath(resource))
                    if File.directory?(file) || !File.exists?(file)
                        status 404
                    else
                        send_file file
                    end 
                end
            end

            app.get '/js/*' do
                cache_control :public, max_age: 60

                resource = params['splat'].first
                if resource.nil? || resource.empty?
                    status 404
                else
                    file = File.join(JS_FOLDER, Utils.strippath(resource))
                    if File.directory?(file) || !File.exists?(file)
                        status 404
                    else
                        send_file file
                    end 
                end
            end
        end
    end
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

define_builder :css, CSSBuilder.new