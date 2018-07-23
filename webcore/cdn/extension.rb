module Webcore
    module CDNExtension
        def self.registered app
            app.get '/cdn/:module/:resource' do |mod, resource|
                m = app.services.webcore.modules[mod.to_sym]
                unless m.nil?
                    service = m.services.cdn
                    r = service[resource.to_sym]
                    unless r.nil?
                        last_modified r.last_modified(request, app)
                        return app.services.memcache.cache_if(r.memcache, "#{m.id.to_s}/#{r.id.to_s}", nil, global: true) do
                            r.respond
                        end
                    end
                end
                [404, nil, nil]
            end
        end
    end
end