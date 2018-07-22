require_relative 'resources/libs'
require_relative 'webcore'

module Webcore
    class Services
        attr_reader :webcore
        attr_reader :libs

        def initialize webcore
            @webcore = webcore
            @libs = Libs.new
        end
    end
end