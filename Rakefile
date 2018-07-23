require 'bundler/setup'

namespace :db do
    desc "Run Migrations"
    task :migrate do
        require 'sequel'
        require_relative 'webcore/db/db'
        Sequel.extension :migration
        Sequel::Migrator.run(Webcore::DB.db, "webcore/db/migrations", table: :webcore_migrations)
    end
end