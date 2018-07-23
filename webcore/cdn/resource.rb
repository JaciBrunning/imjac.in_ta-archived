require 'open-uri'

module Webcore
    class Resource
        attr_accessor :memcache
        attr_accessor :content_type
        attr_reader :id

        def initialize id
            @id = id
            @memcache = false
            @content_type = "text/plain"

            if id.to_s.end_with? ".css"
                @content_type = "text/css"
            elsif id.to_s.end_with?(".js") || id.to_s.end_with?(".jsx")
                @content_type = "application/javascript"
            end
        end

        def respond
            [404, nil, "Resource Not Found"]
        end

        def last_modified request, app
            app.services.webcore.startup_time
        end

        def construct_response content
            headers = {
                "Content-Type" => @content_type
            }
            [200, headers, content]
        end
    end

    class StaticResource < Resource
        attr_reader :content

        def initialize id, content
            super id
            @content = content
        end

        def respond
            construct_response @content
        end
    end

    class FileResource < Resource
        attr_reader :file

        def initialize id, file
            super id
            @file = file
        end

        def respond
            construct_response File.read(@file)
        end
    end

    class BufferResource < Resource
        attr_reader :url

        def initialize id, url
            super id
            @url = url
        end

        def respond
            construct_response open(@url).read
        end
    end

    class RedirectResource < Resource
        attr_reader :url

        def initialize id, url
            super id
            @url = url
        end

        def last_modified request, app
            nil
        end

        def respond
            [302, {"Location" => @url}, nil]
        end
    end
end