require_relative 'job.rb'

module Webcore
    class CronRegistry
        def initialize
            @cronjobs = []
        end

        def register server, id, schedule, endpoint
            job = CronJob.new id, endpoint, server
            job.every! schedule
            @cronjobs << job
            job
        end

        def jobs
            @cronjobs
        end
    end
end