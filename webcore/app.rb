require 'sinatra/base'
require 'sinatra/reloader'

module Webcore
    class App < Sinatra::Base
        configure :development do
            puts "WARNING: DEV MODE!"
        end

        module ClassMethods
            attr_reader :this_module

            def create_app mod
                klass = Class.new(self)
                klass.set_module(mod)
                klass
            end

            def set_module mod
                @this_module = mod
            end

            def inherited subclass
                super
                if self != App
                    # We're in a subclass, copy over the data we need
                    subclass.set_module @this_module
                    # Also register the domain
                    @this_module.register_domain subclass
                end
            end
        end

        module AllMethods
            def services
                this_module.services
            end
        end

        def this_module
            self.class.this_module
        end

        extend ClassMethods
        extend AllMethods
        include AllMethods
    end
end
