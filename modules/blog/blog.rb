require_relative 'constants.rb'
require 'webcore/cdn/extension'

class BlogModule < WebcoreApp()
    set :public_folder, BlogConstants::HTML_DIR
    register CDNExtension

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
            puts "NF"
            status 404
        end
    end

    blog_css = FileResource.new :"blog.css", File.join(BlogConstants::CSS_DIR, "blog.min.css")
    blog_css.memcache = true
    services[:cdn].register blog_css
end