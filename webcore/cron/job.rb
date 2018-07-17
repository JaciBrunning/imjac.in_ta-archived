require_relative 'schedule.rb'

module Webcore
    class CronJob
        attr_reader :id
        attr_reader :schedule
        attr_reader :endpoint
        attr_accessor :description
        attr_accessor :server
        
        def initialize id, endpoint, server
            @id = id
            @paused = false
            @endpoint = endpoint
            @description = nil
            @server = server
        end

        def every! *args
            @schedule = CronSchedule.new *args
        end

        def paused?
            @paused
        end

        def pause
            @paused = true
        end

        def unpause
            @paused = false
        end

        def trigger? time
            !paused? && schedule.trigger?(time)
        end

        def run
            # TODO: Call endpoint
        end

        def to_s
            "CronJob[id=#{id} paused=#{paused?} endpoint=#{endpoint} schedule=#{schedule.to_s}]"
        end
    end
end