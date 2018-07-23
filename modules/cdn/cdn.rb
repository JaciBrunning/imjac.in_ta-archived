require 'webcore/cache/memcache'

class TestModule < WebcoreApp()
    register ::Webcore::Extensions::Memcache
    set :memcache_namespace, "CDN"
    set :memcache_enabled, !development?

    get "/:module/:resource" do |mod, resource|
        m = services.webcore.modules[mod.to_sym]
        unless m.nil?
            service = m.services.cdn
            r = service[resource.to_sym]
            unless r.nil?
                last_modified r.last_modified(request, self)
                if r.memcache
                    cache "#{m.id.to_s}/#{r.id.to_s}" do
                        r.respond
                    end
                else
                    r.respond
                end
            else
                [404, nil, nil]
            end
        else
            [404, nil, nil]
        end
    end

    not_found do
        "The resource you're looking for could not be located!"
    end
end