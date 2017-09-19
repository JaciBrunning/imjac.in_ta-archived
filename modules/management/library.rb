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

        @git.index.reload

        changed_files = []
        @git.status do |file, status|
            unless status.include?(:ignored) || status.empty?
                changed_files << { 
                    name: file, 
                    status: status.include?(:worktree_modified) ? "M" : 
                        status.include?(:worktree_deleted) ? "D" : 
                        "A" 
                }
            end
        end

        status = { branches: [], head: @git.head.name, changed_files: changed_files }

        @git.branches.reject { |x| x.name.include?("HEAD") }.each do |branch|
            commit = branch.target
            status[:branches] << {
                :branch => branch.canonical_name,
                :name => branch.name,
                :commit => {
                    :sha => branch.target_id,
                    :message => commit.message,
                    :author => "#{commit.author[:name]} (#{commit.author[:email]})"
                }
            }
        end

        @gitstatus = status
        puts "[MANAGEMENT] Git updated!"
    end

    def self.gitcommit user, msg, files
        index = @git.index
        files.each { |x| index.add x }
        tree = index.write_tree @git
        ref = 'HEAD'
        author = {:email=>"#{user.email}", :time=>Time.now, :name=>"#{user.username}"}
        new_commit = Rugged::Commit.create(@git,
            :author => author,
            :message => msg,
            :committer => author,
            :parents => [@git.head.target],
            :tree => tree,
            :update_ref => ref)
    end
    Jobs.submit Job.new(:gitupdate) { gitupdate }
end

Libs.register_react :manage_git, "/js/react/management/git.jsx"
Libs.register_react :manage_jobs, "/js/react/management/jobs.jsx"
Libs.register_react :manage_builders, "/js/react/management/builders.jsx"
