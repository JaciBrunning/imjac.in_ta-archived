require 'db/db'

module Database
    class Users
        @db = Database.new_db :users
        @db.query(%{
            CREATE TABLE IF NOT EXISTS users (
                UserID INTEGER,
                Username TEXT NOT NULL COLLATE NOCASE,
                Email TEXT NOT NULL COLLATE NOCASE,
                FirstName TEXT NOT NULL,
                LastName TEXT NOT NULL,
                PassSalt TEXT NOT NULL,
                PassHash TEXT NOT NULL,

                PRIMARY KEY(UserID),
                UNIQUE(Username),
                UNIQUE(Email)
            )
        })
        
        class << self

        end
    end
end