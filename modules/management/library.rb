require 'git'

module Management
    @git = Git.open(web_root())
    @status = nil

    def self.git
        @git
    end

    def self.status
        @status
    end

    def self.update
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
                    :author => {
                        :name => commit.author.name,
                        :email => commit.author.email
                    }
                }
            }
        end

        @status = status
        puts "[MANAGEMENT] Git updated!"
    end
    Jobs.submit Job.new(:gitupdate) { update }
end