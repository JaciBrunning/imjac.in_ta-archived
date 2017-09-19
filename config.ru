require 'rack'
$:.unshift File.dirname(__FILE__)

class SubdomainMiddleware
    def initialize(app, subs, mods)
        @app = app
        @subs = subs
        @mods = Hash[mods.map {|name, mod| [name, mod.new]}]
    end

    def call(env)
        domain = env["HTTP_HOST"][/^[^:]+/]
        @subs.each do |sub|
            if (sub[0] =~ domain)
                return @mods[sub[1]].call(env)
            end
        end

        @app.call(env)
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
        if SUBDOMAINS.select { |x| x[0] == domain_regex }.size == 0
            SUBDOMAINS << [domain_regex, module_sym, options] 
            puts "Registering Subdomain(#{domain_regex.inspect}) -> Module(#{module_sym}) (#{options})..."
        else
            puts "Subdomain(#{domain_regex.inspect}) already registered!"
        end
    end

    def web_root
        File.dirname(__FILE__)
    end
end

require 'prestart'
require 'loader'

Loader.discover
Loader.load

puts "Starting..."
use SubdomainMiddleware, SUBDOMAINS.sort_by { |x| x[2][:priority] }, MODULES
run Proc.new { |env| [404, {}, ['Not Found']] }

require 'startup'
