require 'rack'
$:.unshift File.dirname(__FILE__)

class SubdomainMiddleware
    def initialize(app, sub, mod)
        @app = app
        @sub = sub
        @mod = mod.new
    end

    def call(env)
        domain = env["HTTP_HOST"][/^[^:]+/]
        if @sub[0] =~ domain
            @mod.call(env)
        else
            @app.call(env)
        end
    end
end

MODULES = {}
SUBDOMAINS = []

BUILDERS = {}

module Kernel
    def define_webcore_module sym, clazz
        MODULES[sym] = clazz
        puts "Registering Module(#{sym})..."
    end

    def define_virtual_server domain_regex, module_sym, options={}
        options = { priority: 50 }.merge(options)
        SUBDOMAINS << [domain_regex, module_sym, options]
        puts "Registering Subdomain(#{domain_regex.inspect}) -> Module(#{module_sym}) (#{options})..."
    end

    def define_builder sym, builder
        BUILDERS[sym] = builder
    end

    def get_all_builders
        BUILDERS
    end

    def web_root
        File.dirname(__FILE__)
    end
end

puts "Loading Libraries..."
Dir['modules/**/library.rb'].each do |p|     # Preload files that can be used in other modules (e.g. setting up cross-module APIs)
    puts "Loading Library #{p}..."
    require_relative p
end
puts

puts "Loading Modules..."
Dir['modules/**/module.rb'].each do |p|
    puts "Loading #{p}..."
    require_relative p
end
puts

puts "Building Resources..."
BUILDERS.each do |name, builder|
    puts "Building #{name}..."
    builder.run
end

puts "Starting..."
SUBDOMAINS.sort_by { |x| x[2][:priority] }.each do |sub|
    use SubdomainMiddleware, sub, MODULES[sub[1]]
    run Proc.new { |env| [404, {}, ['Not Found']] }
end