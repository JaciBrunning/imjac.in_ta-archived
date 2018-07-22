module Webcore
    class Libs
        def initialize
            @js = {}
            @css = {}

            register_defaults
        end

        def register_defaults
            register_css :fontawesome, "https://use.fontawesome.com/releases/v5.1.0/css/all.css"
            register_js :react, "https://unpkg.com/react@15/dist/react.min.js", "https://unpkg.com/react-dom@15/dist/react-dom.min.js"
        end

        def register_js id, *uris
            @js[id] ||= []
            @js[id] += uris
        end

        def register_css id, *uris
            @css[id] ||= []
            @css[id] += uris
        end

        def js *ids
            ids.map do |id|
                @js[id].map do |u|
                    "<script type=\"text/javascript\" src=\"#{uri}\"></script>"
                end
            end.flatten.join("\n")
        end

        def css *ids
            ids.map do |id|
                @css[id].map do |u|
                    "<link rel=\"stylesheet\" href=\"#{uri}\">"
                end
            end.flatten.join("\n")
        end

        def js_uris *ids
            ids.map { |id| @js[id] }.flatten
        end

        def css_uris *ids
            ids.map { |id| @css[id] }.flatten
        end
    end
end