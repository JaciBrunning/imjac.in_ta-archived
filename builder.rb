require 'jobs'

class Builder
    def _setname name
        @name = name
    end

    def build
    end

    def clean
    end

    def submit_clean!
        Jobs.submit Job.new("clean_#{@name.to_s}".to_sym) { clean }
    end

    def submit_build!
        Jobs.submit Job.new("build_#{@name.to_s}".to_sym) { build }
    end
end

class Builders
    @builders = {}

    def self.builders
        @builders
    end

    def self.register name, builder
        builder._setname name
        @builders[name] = builder
    end
end