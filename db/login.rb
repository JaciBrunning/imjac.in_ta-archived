require 'db/db'
require 'db/security'
require 'bcrypt'

module Database
    class Login
        @db = Database::connect
        SCHEMA = Sequel[:login]

        # Create Tables
        @db.create_table? SCHEMA[:users] do
            primary_key :id
            String :username, null: false, unique: true
            String :email, null: false, unique: true
            String :name, null: false
            String :pass_salt, null: false
            String :pass_hash, null: false
            Boolean :superuser, default: false

            index Sequel.function(:lower, :username), :unique => true
            index Sequel.function(:lower, :email), :unique => true
        end

        @db.create_table? SCHEMA[:user_tokens] do
            primary_key :id
            foreign_key :user_id, SCHEMA[:users], on_delete: :cascade
            String :tok_string, null: false, unique: true
            Time :leased_time, null: false
            Time :expire_time, null: false
        end

        # Model Classes
        class User < Sequel::Model(@db[SCHEMA[:users]])
        end

        class UserToken < Sequel::Model(@db[SCHEMA[:user_tokens]])
            many_to_one :user
        end

        class << self
            def db
                @db
            end

            def login_password login, pass
                user = User.where(Sequel.ilike(:username, login)).or(Sequel.ilike(:email, login))
                return :nouser if user.nil? || user.empty?
                user = user.first
                if (user.pass_hash == Security::hash(pass, user.pass_salt))
                    # Grant Token
                    time = Time.now
                    expire = time + 1*7*24*60*60 # 1 week
                    tokenstring = Security::hash "#{user.username}#{time.to_i}", Security::salt
                    UserToken.create user: user, tok_string: tokenstring, leased_time: time, expire_time: expire
                else
                    return :wrong
                end
            end

            def login_token token
                return :notoken if token.nil?
                tok = UserToken.first(tok_string: token)
                return :notoken if tok.nil?
                if Time.now > tok.expire_time
                    UserToken[tok.id].delete
                    return :expired
                end
                tok.update(expire_time: Time.now + 1*7*24*60*60)
                UserToken.where { expire_time < Time.now }.delete   # Delete expired tokens to clear database space
                return tok
            end

            def deauth_single token
                return if token.nil?
                UserToken.where(tok_string: token).delete
            end

            def create username, email, name, pass, superuser=false
                salt = Security::salt
                hash = Security::hash pass, salt

                begin
                    User.create username: username, email: email, name: name, pass_salt: salt, pass_hash: hash, superuser: superuser
                rescue => e
                    :exists
                end
            end
        end
    end
end