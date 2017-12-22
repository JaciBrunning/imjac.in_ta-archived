require 'sequel'
require 'fileutils'

module Database
    def self.connect
        Sequel.connect(ENV['WEBCORE_DB_URL'].strip)
    end

    def self.wrap_validation error_callback, &block
        begin
            obj = yield
            unless obj.valid?
                error_callback.call(obj.errors.full_messages.map(&:capitalize))
                return false
            end
            true
        rescue Sequel::UniqueConstraintViolation
            error_callback.call(['Key already exists in database'])
            false
        rescue Sequel::NotNullConstraintViolation
            error_callback.call(['Values cannot be null!'])
            false
        rescue Sequel::ValidationFailed => e
            error_callback.call(e.errors.full_messages.map(&:capitalize))
            return
        rescue => e
            puts e.type
            error_callback.call(['An Unknown Error Occured'])
            false
        end
    end
end