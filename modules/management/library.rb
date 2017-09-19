require 'rugged'
require 'libs'

module Management
    @git = Rugged::Repository.new(web_root())
    @gitstatus = nil

    def self.git
        @git
    end

    def self.gitstatus
        @gitstatus
    end

    def self.gitupdate
        puts "[MANAGEMENT] Updating git..."

        # @git.remotes['origin'].fetch.save    TODO: Prompt password for git things

        branchname = @git.head.name.sub(/^refs\/heads\//, '')

        branch = @git.branches[branchname]
        rbranch = @git.branches["origin/#{branchname}"]

        # puts @git.diff.map { |f| f.path }

        status = {  }

        {:local => branch, :remote => rbranch}.each do |key, branch|
            commit = branch.target
            status[key] = {
                :branch => branch.name,
                :commit => {
                    :raw => commit,
                    :sha => branch.target_id,
                    :msg => commit.message,
                    :author => "#{commit.author[:name]} (#{commit.author[:email]})"
                }
            }
        end

        @gitstatus = status
        puts "[MANAGEMENT] Git updated!"
    end
    Jobs.submit Job.new(:gitupdate) { gitupdate }
end

Libs.register_react :manage_git, "/js/react/management/git.jsx"
Libs.register_react :manage_jobs, "/js/react/management/jobs.jsx"
Libs.register_react :manage_builders, "/js/react/management/builders.jsx"
