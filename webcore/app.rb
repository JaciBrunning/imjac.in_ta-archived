require 'sinatra/base'
require 'sinatra/reloader'

module Webcore
    class App < Sinatra::Base
        configure :development do
            puts "WARNING: DEV MODE!"
            register Sinatra::Reloader
        end

        module ClassMethods
            attr_reader :webcore_module

            def create_app mod
                klass = Class.new(self)
                klass.set_module(mod)
                klass
            end

            def set_module mod
                @webcore_module = mod
            end

            def inherited subclass
                super
                if self != App
                    # We're in a subclass, copy over the data we need
                    subclass.set_module @webcore_module
                    # Also register the domain
                    @webcore_module.register_domain subclass
                end
            end
        end

        def webcore_module
            self.class.webcore_module
        end

        extend ClassMethods
    end
end
