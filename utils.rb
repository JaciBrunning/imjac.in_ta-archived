module Utils
    def self.strippath path
        path.sub('\\', '/').split('/').reject { |x| x == '..' }.join('/')
    end
end