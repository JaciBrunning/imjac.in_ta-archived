require 'git'
require 'libs'

module Management
    @git = Git.open(web_root())
    @gitstatus = nil

    def self.git
        @git
    end

    def self.gitstatus
        @gitstatus
    end

    def self.gitupdate
        puts "[MANAGEMENT] Updating git..."
        @git.fetch
        branch = @git.branch
        rbranch = @git.branches["origin/#{branch.name}"]

        status = { :changed => @git.status.changed.size, :untracked => @git.status.untracked.size }

        {:local => branch, :remote => rbranch}.each do |key, branch|
            commit = branch.gcommit
            status[key] = {
                :branch => branch,
                :commit => {
                    :raw => commit,
                    :sha => commit.sha,
                    :msg => commit.message,
                    :author => "#{commit.author.name} (#{commit.author.email})"
                }
            }
        end

        @gitstatus = status
        puts "[MANAGEMENT] Git updated!"
    end
    Jobs.submit Job.new(:gitupdate) { gitupdate }
end

Libs.register_react :manage_git, "/js/react/git.jsx"
Libs.register_react :manage_jobs, "/js/react/jobs.jsx"
Libs.register_react :manage_builders, "/js/react/builders.jsx"