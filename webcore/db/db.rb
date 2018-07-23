require 'sequel'

module Webcore
    class DB
        class << self
            def db
                @db ||= Sequel.connect(ENV["WEBCORE_DB_URL"] || 'postgres://web:web@localhost/web')
            end
        end
    end
end