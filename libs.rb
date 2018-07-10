module Libs
    @jslibs = {}
    @csslibs = {}

    def self.register_js name, *uris
        if @jslibs[name].nil?
            @jslibs[name] = uris
        else
            @jslibs[name] += uris
        end
    end

    def self.register_css name, *uris
        if @csslibs[name].nil?
            @csslibs[name] = uris
        else
            @csslibs[name] += uris
        end
    end

    def self.js *names
        names.map { |name| @jslibs[name].map { |uri| "<script type=\"text/javascript\" src=\"#{uri}\"></script>" } }.flatten.join("\n")
    end

    def self.css *names
        names.map { |name| @csslibs[name].map { |uri| "<link rel=\"stylesheet\" href=\"#{uri}\">" } }.flatten.join("\n")
    end
end

Libs.register_css :fontawesome, "https://use.fontawesome.com/releases/v5.1.0/css/all.css"
Libs.register_js :react, "https://unpkg.com/react@15/dist/react.min.js", "https://unpkg.com/react-dom@15/dist/react-dom.min.js"