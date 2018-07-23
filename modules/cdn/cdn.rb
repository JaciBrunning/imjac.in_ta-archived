require 'webcore/cdn/extension'

class CDNModule < WebcoreApp()
    register ::Webcore::CDNExtension

    get "/:module/:resource/?" do |mod, resource|
        redirect "/cdn/#{mod}/#{resource}"
    end

    get "/:resource/?" do |resource|
        redirect "/cdn/#{resource}"
    end

    {
        "milligram.css": "http://cdnjs.cloudflare.com/ajax/libs/milligram/1.3.0/milligram.min.css",
        "fontawesome.css": "http://use.fontawesome.com/releases/v5.1.0/css/all.css"
    }.each do |key, value|
        r = RedirectResource.new(key.to_sym, value)
        r.memcache = true
        services.cdn.register r
    end

    not_found do
        "The resource you're looking for could not be located!"
    end
end