set :application, 'imjac.in_ta'

set :repo_url, 'https://github.com/JacisNonsense/imjac.in_ta.git'
set :branch, 'master'

set :user, 'deploy'

namespace :deploy do
    desc "Run rake tasks"
    task :rake_install do
        on roles(:app) do
            within release_path do
                execute "rake", "install"
            end
        end
    end

    after "bundler:install", "deploy:rake_install"
    after :deploy, "service:restart"
end

namespace :service do
    desc "Restart Webcore Service"
    task :restart do
        on roles(:app) do
            execute "sudo systemctl restart webcore.service"
        end
    end
    
    after :deploy, "service:restart"
end