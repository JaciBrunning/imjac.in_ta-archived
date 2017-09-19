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

    def self.load_libs
        puts "[LOADER] Loading Libraries..."
        Dir['modules/**/library.rb'].each do |p|     # Preload files that can be used in other modules (e.g. setting up cross-module APIs)
            puts "[LOADER] Loading lib #{p}..."
            @libs << p
            require_relative p
        end
        puts
    end

    def self.load_mods
        puts "[LOADER] Loading Modules..."
        Dir['modules/**/module.rb'].each do |p|
            puts "[LOADER] Loading mod #{p}..."
            @mods << p
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