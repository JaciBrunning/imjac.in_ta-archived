require 'sinatra/base'
require 'sinatra-websocket'
require 'jobs'
require 'utils'
require 'libs'
require 'json'
require 'builder'
require 'loader'

class ManagementModule < Sinatra::Base
    register Extensions::Resources
    register Extensions::Auth

    get "/?" do
        auth_su!
        @title = "Management Console"
        erb :index
    end

    get "/ta/?" do
        redirect "/"
    end

    get "/login" do
        @title = "Management Console"
        erb :login
    end

    post "/newuser" do
        redirect "/login" unless Database::Login::User.count == 0
        Database::Login::create params[:username], params[:email], params[:name], params[:password], true
        redirect "/login"
    end

    get "/ws/jobs" do
        auth!
        redirect "/" if !request.websocket?
        request.websocket do |ws|
            ws.onopen do
            end

            ws.onmessage do |msg|
                if msg == "update"
                    qd = Jobs.jobs.map do |job|
                        qt = Time.now - (job.submit_time + job.delay)
                        {
                            name: job.name, 
                            cancelled: job.cancelled?,
                            recurring: job.recurring? ? "Every #{Utils.render_time_delay(job.delay)}" : "-",
                            time: job.immediate ? "ASAP" : qt > 0 ? "Overdue(#{Utils.render_time_delay(qt)})" : "Delayed(#{Utils.render_time_delay(-qt)})",
                            hash: job.hash.to_s
                        }
                    end
                    workers = Jobs.current_jobs.each_with_index.map do |job, idx|
                        {
                            id: idx, 
                            job: job.nil? ? "-" : job.name,
                            hash: job.hash.to_s
                        }
                    end
                    ws.send JSON.generate({ workers: workers, queued: qd })
                else
                    data = JSON.parse msg
                    Jobs.jobs.select { |x| x.hash.to_s == data["job"] }.first.cancel if data["action"] == "cancel"
                    Jobs.jobs.select { |x| x.hash.to_s == data["job"] }.first.immediate = true if data["action"] == "immediate"
                end
            end

            ws.onclose do
            end
        end
    end

    get "/ws/builders" do
        auth!
        redirect "/" if !request.websocket?
        request.websocket do |ws|
            ws.onopen do
                builders = Builders.builders.map do |name, builder|
                    {
                        name: name, type: builder.class.name
                    }
                end
                ws.send JSON.generate({ builders: builders })
            end

            ws.onmessage do |msg|
                data = JSON.parse msg
                if data["action"] == "clean"
                    Builders.builders[data["builder"].to_sym].submit_clean!
                elsif data["action"] == "build"
                    Builders.builders[data["builder"].to_sym].submit_build!
                end
            end

            ws.onclose do
            end
        end
    end
end

define_webcore_module :management, ManagementModule
define_virtual_server /manage.*/, :management

_builder = JSBuilder.new(
    File.join(File.dirname(__FILE__), 'jsx'),
    out: 'react/management',
    lib: :management
)
Builders.register :management_jsx, _builder