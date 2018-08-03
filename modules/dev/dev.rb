require 'webcore/cdn/extension'
require 'pathname'
require 'fileutils'

class BlogModule < WebcoreApp()
    register CDNExtension
    set :public_folder, "#{File.dirname(__FILE__)}/_public"
    set :views, "#{File.dirname(__FILE__)}/views"

    FileUtils.mkdir_p settings.public_folder

    get "/ta/?" do
        redirect "/"
    end

    get '*' do |path|
        file = File.join(settings.public_folder, strippath(path))
        if File.exist?(file)
            if File.directory?(file)
                @directory = file
                @path = strippath(path)
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

    def strippath path
        path.sub('\\', '/').split('/').reject { |x| x == '..' }.join('/')
    end

    FILESIZE_PREFIXES = %w{k M G T P E Z Y}
    def filesize bytes
        if bytes < 1000
           bytes.to_s + "B"
        else
            pos = (Math.log(bytes) / Math.log(1000)).floor
            pos = FILESIZE_PREFIXES.size - 1 if pos > FILESIZE_PREFIXES.size-1

            unit = FILESIZE_PREFIXES[pos-1] + "B"
            (bytes.to_f / 1000**pos).round(2).to_s + unit
        end
    end
end