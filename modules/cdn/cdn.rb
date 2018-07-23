require 'webcore/cdn/extension'

class CDNModule < WebcoreApp()
    register ::Webcore::CDNExtension

    get "/:module/:resource" do |mod, resource|
        redirect "/cdn/#{mod}/#{resource}"
    end

    not_found do
        "The resource you're looking for could not be located!"
    end
end