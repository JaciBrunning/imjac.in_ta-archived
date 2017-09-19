class Builder

    class << self
        def build &block
            @buildstages ||= []
            @buildstages << block
        end

        def clean &block
            @cleanstages ||= []
            @cleanstages << block
        end

        def run_build
            @buildstages ||= []
            @buildstages.each { |stage| stage.call() }
        end

        def run_clean
            @cleanstages ||= []
            @cleanstages.each { |stage| stage.call() }
        end
    end

    def run_build
        self.class.run_build
    end

    def run_clean
        self.class.run_clean
    end
end

class Builders
    @builders = {}

    def self.builders
        @builders
    end

    def self.register name, builder
        @builders[name] = builder
    end
end