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

    def run
        puts "-> Running Builder #{self.class.name}"
        self.class.run_clean
        self.class.run_build
    end
end