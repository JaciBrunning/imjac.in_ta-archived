module Webcore
    module CDNExtension
        def self.registered app
            app.get '/cdn/:module/:resource/?' do |mod, resource|
                mod = app.services.webcore.modules[mod.to_sym]
                unless mod.nil?
                    service = mod.services.cdn
                    r = service[resource.to_sym]
                    unless r.nil?
                        last_modified r.last_modified(request, app)
                        app.services.memcache.cache_if(r.memcache, "#{mod.id.to_s}/#{r.id.to_s}", nil, global: true) do
                            r.respond
                        end
                    else 
                        [404, nil, nil]
                    end
                else
                    [404, nil, nil]
                end
            end

            app.get '/cdn/:resource/?' do |resource|
                redirect "/cdn/#{this_module.id}/#{resource}"
            end
        end
    end
end