require 'sequel'
require 'fileutils'

module Database
    def self.connect
        Sequel.connect(ENV['WEBCORE_DB_URL'].strip)
    end
end