require_relative 'cdn/cdn'
require_relative 'webcore'

module Webcore
    class Services
        attr_reader :webcore
        attr_reader :cdn

        def initialize webcore
            @webcore = webcore
            @cdn = CDNService.new
        end
    end
end