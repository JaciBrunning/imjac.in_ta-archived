# Load DSL and Setup Up Stages
require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/bundler'
require 'capistrano/rvm'
require 'capistrano/scm/git'

install_plugin Capistrano::SCM::Git

Dir.glob('automation/tasks/*.rake').each { |r| import r }