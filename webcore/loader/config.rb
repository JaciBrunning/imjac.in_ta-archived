module Webcore
    class ModuleConfiguration
        attr_accessor :id
        attr_accessor :module
        attr_accessor :dependsOn
        attr_accessor :mustLoadAfter
        
        attr_accessor :file

        @mustLoadAfter = []
        @dependsOn = []
    end
end