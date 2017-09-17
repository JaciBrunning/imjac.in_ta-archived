require 'sequel'
require 'fileutils'

module Database
    @dbs = {}
    @dbroot = File.join(web_root(), "_db")
    FileUtils.mkdir_p(@dbroot)

    def self.dbroot
        @dbroot
    end

    def self.new_db name, file=nil
        file = File.join(@dbroot, "#{name}.sqlite") if file.nil?
        @dbs[name] = Sequel.connect("sqlite:///#{file}")
    end

    def self.get name
        @dbs[name]
    end
end