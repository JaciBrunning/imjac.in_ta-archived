require 'sqlite3'

module Database
    @dbs = {}
    @dbroot = File.join(web_root(), "_db")
    FileUtils.mkdir_p(@dbroot)

    def self.dbroot
        @dbroot
    end

    class DB
        attr_accessor :file
        attr_accessor :db

        def initialize name, file
            @file = file
            @db = SQLite3::Database.new @file
            @db.results_as_hash = true

            @db.execute "PRAGMA foreign_keys = ON"
        end

        def transaction
            @db.transaction
        end

        def commit
            @db.commit
        end

        def query sql, *data
            sql = sql.split(";") if sql.is_a?(String)
            data = [data] if sql.size == 1
            sql.zip(data).map { |s, d| @db.execute(s, d) }
        end
    end

    def self.new_db name, file=nil
        file = File.join(@dbroot, "#{name}.sql") if file.nil?
        @dbs[name] = DB.new(name, file)
    end

    def self.get name
        @dbs[name]
    end
end