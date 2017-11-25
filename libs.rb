module Libs
    @jslibs = {}
    @csslibs = {}

    def self.register_js name, *uris
        @jslibs[name] = uris
    end

    def self.register_css name, *uris
        @csslibs[name] = uris
    end

    def self.js *names
        names.map { |name| @jslibs[name].map { |uri| "<script type=\"text/javascript\" src=\"#{uri}\"></script>" } }.flatten.join("\n")
    end

    def self.css *names
        names.map { |name| @csslibs[name].map { |uri| "<link rel=\"stylesheet\" href=\"#{uri}\">" } }.flatten.join("\n")
    end
end

Libs.register_css :jaci, "/res/css/milligram_jaci.css"
Libs.register_css :fontawesome, "https://use.fontawesome.com/b730a09ebb.css"

Libs.register_js :react, "https://unpkg.com/react@15/dist/react.min.js", "https://unpkg.com/react-dom@15/dist/react-dom.min.js"