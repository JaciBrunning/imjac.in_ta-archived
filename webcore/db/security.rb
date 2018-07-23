require 'bcrypt'
require 'aescrypt'
require 'base64'

module Webcore
    module Security
        def self.salt
            BCrypt::Engine.generate_salt(10)
        end

        def self.hash pass, salt
            BCrypt::Engine.hash_secret(pass, salt)
        end

        def self.encrypt data, secret
            AESCrypt.encrypt data, secret
        end

        def self.decrypt data, secret
            begin
                AESCrypt.decrypt data, secret
            rescue => e
                nil
            end
        end
    end
end