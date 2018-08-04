server ENV['DEPLOY_SERVER'], roles: [:web, :app, :db], primary: true, ssh_options: { user: 'deploy' }

set :deploy_to, '/etc/www/webcore/modules'