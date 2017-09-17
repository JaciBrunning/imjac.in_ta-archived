require 'sinatra/base'
require 'sinatra-websocket'
require 'jobs'
require 'utils'
require 'libs'
require 'json'

class ManagementModule < Sinatra::Base
    register Extensions::Resources
    register Extensions::Auth

    get "/?" do
        auth!
        @title = "Management Console"
        @js = [ :react ]
        @react = [ :manage_git, :manage_jobs, :manage_builders ]
        erb :index
    end

    get "/login" do
        redirect "/" if auth?
        @title = "Management Console"
        erb :login
    end

    post "/newuser" do
        redirect "/login" unless Database::Users::User.count == 0
        Database::Users::create params[:username], params[:email], params[:name], params[:password]
        redirect "/login"
    end

    get "/test" do
        @js = [ :react ]
        erb :test
    end

    get "/ws/git" do
        auth!
        redirect "/" if !request.websocket?
        request.websocket do |ws|
            ws.onopen do
                ws.send JSON.generate(Management.gitstatus)
            end

            ws.onmessage do |msg|
                Jobs.submit Job.new(:gitupdate) { 
                    Management.gitupdate
                    ws.send JSON.generate(Management.gitstatus)
                }
            end

            ws.onclose do
            end
        end
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
                            hash: job.hash
                        }
                    end
                    workers = Jobs.current_jobs.each_with_index.map do |job, idx|
                        {
                            id: idx, 
                            job: job.nil? ? "-" : job.name,
                            hash: job.hash
                        }
                    end
                    ws.send JSON.generate({ workers: workers, queued: qd })
                else
                    data = JSON.parse msg
                    Jobs.jobs.select { |x| x.hash == data["job"] }.first.cancel if data["action"] == "cancel"
                    Jobs.jobs.select { |x| x.hash == data["job"] }.first.immediate = true if data["action"] == "immediate"
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
                builders = get_all_builders.map do |name, builder|
                    {
                        name: name, type: builder.class.name
                    }
                end
                ws.send JSON.generate({ builders: builders })
            end

            ws.onmessage do |msg|
                data = JSON.parse msg
                if data["action"] == "clean"
                    Jobs.submit Job.new("clean_#{data["builder"]}".to_sym) { 
                        get_all_builders[data["builder"].to_sym].run_clean
                    }
                elsif data["action"] == "build"
                    Jobs.submit Job.new("build_#{data["builder"]}".to_sym) { 
                        get_all_builders[data["builder"].to_sym].run_build
                    }
                end
            end

            ws.onclose do
            end
        end
    end

    # get "/actions/git/update" do
    #     auth!
    #     Management.update
    #     redirect "/"
    # end

    # get "/actions/git/stage" do
    #     Management.git.add(:all => true)    # TODO make a dialog for this
    #     redirect "/"
    # end

    # get "/actions/git/confirm_commit" do
    #     erb :confirm_commit
    # end

    # post "/actions/git/commit" do
    #     puts params[:commit_message]        # TODO implement commit
    #     Management.update
    #     redirect "/"
    # end

    # get "/actions/git/confirm_reset" do
    #     erb :confirm_reset
    # end

    # post "/actions/git/reset" do
    #     # Management.git.reset_hard
    #     redirect "/"
    # end

    # get "/actions/git/pull" do
    #     Management.git.pull
    #     Management.update
    #     redirect "/"
    # end

    # get "/actions/git/push" do
    #     Management.git.push
    #     redirect "/"
    # end

    # get "/actions/builder/:builder/clean" do
    #     builder = params[:builder]
    #     Jobs.submit Job.new("clean_#{builder}".to_sym) { get_all_builders[builder.to_sym].run_clean }
    #     redirect "/"
    # end

    # get "/actions/builder/:builder/build" do
    #     builder = params[:builder]
    #     Jobs.submit Job.new("build_#{builder}".to_sym) { get_all_builders[builder.to_sym].run_build }
    #     redirect "/"
    # end

    # get "/action/queue/donow/:jobidx" do
    #     Jobs.jobs[params[:jobidx].to_i].immediate = true
    #     redirect "/"
    # end

end

define_webcore_module :management, ManagementModule
define_virtual_server /manage.*/, :management