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
end

Dir['modules/**/library.rb'].each do |p|     # Preload files that can be used in other modules (e.g. setting up cross-module APIs)
    puts "Preloading Library #{p}..."
    require_relative p
end

Dir['modules/**/module.rb'].each do |p|
    puts "Loading #{p}..."
    require_relative p
end


SUBDOMAINS.sort_by { |x| x[2][:priority] }.each do |sub|
    use SubdomainMiddleware, sub, MODULES[sub[1]]
    run Proc.new { |env| [404, {}, ['Not Found']] }
end