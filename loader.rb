require 'yaml'
module Loader
    @libs = []
    @mods = []
    @exts = []

    def self.libs
        @libs
    end

    def self.mods
        @mods
    end

    def self.exts
        @exts
    end

    def self.discover
        search_path = ['modules']
        search_path += ENV['WEB_MOD_PATH'].split(':') unless ENV['WEB_MOD_PATH'].nil?
        puts "[LOADER] Discovering..."
        search_path.each do |path|
            Dir[File.join(path, '**/module.yml')].each do |p|
                puts "[LOADER] Discovered Module Config: #{p}"
                prepare(File.dirname(p), parse_module_yml(File.read(p)))
            end
        end
    end

    def self.parse_module_yml contents
        YAML.load contents
    end

    def self.prepare root, descriptor
        @libs += descriptor["libraries"].map { |x| File.join(root, x) } if descriptor["libraries"]
        @mods += descriptor["modules"].map { |x| File.join(root, x) }   if descriptor["modules"]
    end

    def self.load_libs
        puts "[LOADER] Loading Libraries..."
        @libs.each do |p|     # Preload files that can be used in other modules (e.g. setting up cross-module APIs)
            puts "[LOADER] Loading lib #{p}..."
            require_relative p
        end
        puts
    end

    def self.load_mods
        puts "[LOADER] Loading Modules..."
        @mods.each do |p|
            puts "[LOADER] Loading mod #{p}..."
            require_relative p
        end
        puts
    end

    def self.load_exts
        puts "[LOADER] Loading Extensions..."
        Dir['extensions/**.rb'].each do |p|
            puts "[LOADER] Loading Ext #{p}..."
            @exts << p
            require_relative p
        end
        puts
    end

    def self.load
        load_exts
        load_libs
        load_mods
    end
end