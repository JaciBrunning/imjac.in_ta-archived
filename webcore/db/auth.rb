require_relative 'db'
require_relative 'security'

module Webcore
    class Auth
        SCHEMA = Sequel[:auth]

        class User < Sequel::Model(DB.db[SCHEMA[:users]])
            plugin :uuid, field: :id

            def validate
                super
                errors.add(:username, 'is not valid (A-Z,0-9,_ only)') unless username =~ /^[A-Za-z0-9_]+$/
                errors.add(:username, 'is too long') if username.size > 32
                errors.add(:email, 'is not a valid email address') unless email =~ /\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i
                errors.add(:email, 'is too long') if email.size > 90
                errors.add(:name, 'is too long') if name.size > 90
            end
        end

        class Token < Sequel::Model(DB.db[SCHEMA[:tokens]])
            plugin :uuid, field: :id
            many_to_one :user
        end

        class << self
            def user login
                User.where(Sequel.ilike(:username, login)).or(Sequel.ilike(:email, login))
            end

            def login_password login, pass
                user = user(login)
                return :nouser if user.nil? || user.empty?
                user = user.first

                if (user.pass_hash == Security::hash(pass, user.pass_salt))
                    # Grant Token
                    time = DateTime.now
                    expire = time + 1*7*24*60*60 # 1 week
                    Token.create user: user, leased_time: time, expire_time: expire
                else
                    :wrong
                end
            end

            def login_token token
                return :notoken if token.nil?
                tok = Token.first(id: token)
                return :notoken if tok.nil?
                if Time.now > tok.expire_time
                    Token[tok.id].delete
                    return :expired
                end
                tok.update(expire_time: Time.now + 1*7*24*60*60)
                expire_tokens
                tok
            end

            def expire_tokens
                Token.where { expire_time < DateTime.now }.delete
            end

            def deauth_single token
                return if token.nil?
                Token.where(id: token).delete
            end

            def create username, email, name, pass, superuser=false
                salt = Security::salt
                hash = Security::hash pass, salt

                User.create username: username, email: email, name: name, pass_salt: salt, pass_hash: hash, superuser: superuser
            end
        end
    end
end