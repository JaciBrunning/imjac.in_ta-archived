require 'fileutils'

require_relative 'constants.rb'

namespace :blog do
    desc "Build Blog"
    task :build => ["jekyll:build", "sass:build"]

    desc "Clean Blog"
    task :clean do
        FileUtils.rm_r BlogConstants::BUILD_DIR
    end

    namespace :jekyll do
        jekyll_dest = "#{BlogConstants::HTML_DIR}/ta"

        desc "Build Jekyll"
        task :build do
            require 'jekyll'

            conf = Jekyll.configuration({
                'source' => "#{BlogConstants::BLOG_DIR}/jekyll",
                'destination' => jekyll_dest
            })
            FileUtils.mkdir_p jekyll_dest
            Jekyll::Site.new(conf).process
        end
    end

    namespace :sass do
        desc "Build Sass"
        task :build do
            require 'sass'

            engine = Sass::Engine.for_file("#{BlogConstants::BLOG_DIR}/css/sass/blog/blog.scss", { 
                style: :compressed,
            })
            FileUtils.mkdir_p "#{BlogConstants::CSS_DIR}"
            File.write("#{BlogConstants::CSS_DIR}/blog.min.css", engine.render)
        end
    end
end