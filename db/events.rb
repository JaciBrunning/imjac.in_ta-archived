require 'wisper'

module Events
    class EventHandler
        include Wisper::Publisher
        def submit obj, key=:update
            broadcast(key, obj)
        end
    end

    # To be included from a Sequel::Model class
    module EventModel
        module ClassMethods
            def event
                @eh ||= EventHandler.new
                @eh
            end
        end

        def after_save
            self.class.event.submit self, :update
            super
        end

        def after_destroy
            self.class.event.submit self, :destroy
            super
        end

        def self.included base
            base.extend ClassMethods
        end
    end
end