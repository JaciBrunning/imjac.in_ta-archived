require 'webcore/base'

class TestModule < ::Webcore::Base
    get "/" do
        puts env
        "HELLO 2"
    end

    get "/cron" do
        puts "CRON TRIGGERED: "
    end
end

@webcore.domains.register :test, /.*/, TestModule.new
@webcore.cron.register @webcore.domains[:test].server, :cron1, "0 0 0 0 0", "/cron"

puts "Calling..."
@webcore.cron.jobs.each(&:run)