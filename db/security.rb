require 'bcrypt'

module Database
    module Security
        def self.salt
            BCrypt::Engine.generate_salt(10)
        end

        def self.hash pass, salt
            BCrypt::Engine.hash_secret(pass, salt)
        end
    end
end