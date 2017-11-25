require 'builder'
require 'fileutils'
require 'utils'
require 'babel/transpiler'
require 'pathname'
require 'libs'

RES_BUILD_FOLDER = File.join(web_root(), '_build/resources')
CSS_BUILD_FOLDER = File.join(RES_BUILD_FOLDER, 'css')

# TODO: Switch this over to a minified version for prod
JS_FOLDER = File.join(web_root(), 'js')
JS_BUILD_FOLDER = File.join(RES_BUILD_FOLDER, 'js')

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
        end
    end
end

class CSSBuilder < Builder
    def initialize cssfile, cssname, options={}
        options[:includes] ||= [ File.join(web_root(), 'css/sass') ]

        @options = options
        @cssfile = cssfile
        @cssname = cssname
        @outfile = File.join(CSS_BUILD_FOLDER, @cssname)

        Libs.register_css options[:lib], "/res/#{Pathname.new(@outfile).relative_path_from(Pathname.new(RES_BUILD_FOLDER)).to_s}" unless options[:lib].nil?
    end

    def clean
        File.delete(@outfile) if File.exists?(@outfile)
    end

    def build
        FileUtils.mkdir_p File.dirname(@outfile)
        `sass #{@options[:includes].map { |x| "-I #{x}" }.join(' ')} -t compressed -E 'UTF-8' #{@cssfile} #{@outfile}` 
    end
end

class JSBuilder < Builder
    def initialize jsdir, options={}
        options[:react] ||= true
        options[:out] ||= @react ? "react/#{File.basename(jsdir)}" : File.basename(jsdir)

        @jsdir = jsdir
        @react = options[:react]
        @outdir = File.join(JS_BUILD_FOLDER, options[:out])

        @files = (Dir["#{@jsdir}/**/*.jsx"] + Dir["#{@jsdir}/**/*.js"])
        @outfiles = @files.map do |jsfile|
            relative = Pathname.new(jsfile).relative_path_from(Pathname.new(@jsdir)).to_s
            outfile = File.join(@outdir, relative)
            outfile = "#{File.dirname(outfile)}/#{File.basename(outfile, '.*')}.js"
            outfile
        end

        unless options[:lib].nil?
            @outfiles.each do |outfile|
                # Assumes proc if not symbol
                name = options[:lib].is_a?(Symbol) ? options[:lib] : options[:lib].call(outfile)
                Libs.register_js name, "/res/#{Pathname.new(outfile).relative_path_from(Pathname.new(RES_BUILD_FOLDER)).to_s}"
            end
        end
    end

    def clean 
        FileUtils.rm_r(@outdir) if File.exists?(@outdir)
    end

    def build
        @files.each_with_index do |jsfile, i|
            outfile = @outfiles[i]
            FileUtils.mkdir_p File.dirname(outfile)
            File.write(outfile, Babel::Transpiler.transform(File.read(jsfile))['code'])
        end
    end
end

Builders.register :css,      CSSBuilder.new(File.join(web_root(), 'css/sass/milligram_jaci/milligram_jaci.sass'), 'milligram_jaci.css', lib: :jaci)
Builders.register :css_blog, CSSBuilder.new(File.join(web_root(), 'css/sass/blog/blog.scss'), 'blog.css')
# Builders.register :jsx,         JSBuilder.new(File.join(web_root(), 'jsx'))