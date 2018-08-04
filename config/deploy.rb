set :application, 'imjac.in_ta'

set :repo_url, 'https://github.com/JacisNonsense/imjac.in_ta.git'
set :branch, 'restructure'

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

    desc "Link Maven Dev"
    task :dev_maven do
        on roles(:app) do
            execute "mkdir -p #{release_path}/modules/dev/_public"
            execute "ln -sf /home/maven/public #{release_path}/modules/dev/_public/maven"
        end
    end

    after "bundler:install", "deploy:rake_install"
    after "deploy:rake_install", "deploy:dev_maven"
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