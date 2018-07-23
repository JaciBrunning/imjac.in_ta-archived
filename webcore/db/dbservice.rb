require 'sequel'

module Webcore
    class DBService
        attr_reader :db

        def initialize url
            @db = Sequel.connect(url)
        end
    end
end