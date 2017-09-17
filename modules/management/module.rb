require 'sinatra/base'
require 'jobs'
require 'utils'
require 'libs'

class ManagementModule < Sinatra::Base
    register Extensions::Resources
    register Extensions::Auth

    get "/?" do
        auth!
        @title = "Management Console"
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

    get "/actions/git/update" do
        auth!
        Management.update
        redirect "/"
    end

    get "/actions/git/stage" do
        Management.git.add(:all => true)    # TODO make a dialog for this
        redirect "/"
    end

    get "/actions/git/confirm_commit" do
        erb :confirm_commit
    end

    post "/actions/git/commit" do
        puts params[:commit_message]        # TODO implement commit
        Management.update
        redirect "/"
    end

    get "/actions/git/confirm_reset" do
        erb :confirm_reset
    end

    post "/actions/git/reset" do
        # Management.git.reset_hard
        redirect "/"
    end

    get "/actions/git/pull" do
        Management.git.pull
        Management.update
        redirect "/"
    end

    get "/actions/git/push" do
        Management.git.push
        redirect "/"
    end

    get "/actions/builder/:builder/clean" do
        builder = params[:builder]
        Jobs.submit Job.new("clean_#{builder}".to_sym) { get_all_builders[builder.to_sym].run_clean }
        redirect "/"
    end

    get "/actions/builder/:builder/build" do
        builder = params[:builder]
        Jobs.submit Job.new("build_#{builder}".to_sym) { get_all_builders[builder.to_sym].run_build }
        redirect "/"
    end

    get "/action/queue/donow/:jobidx" do
        Jobs.jobs[params[:jobidx].to_i].immediate = true
        redirect "/"
    end

end

define_webcore_module :management, ManagementModule
define_virtual_server /manage.*/, :management