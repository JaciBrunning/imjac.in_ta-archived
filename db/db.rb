require 'sequel'
require 'fileutils'

module Database
    class MiscError < StandardError
    end

    def self.connect
        Sequel.connect(ENV['WEBCORE_DB_URL'] || 'postgres://web:web@localhost/web')
    end

    def self.wrap_validation error_callback, &block
        begin
            yield
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
        rescue MiscError => e
            error_callback.call([e.message])
        rescue => e
            puts "[VAL] Validation Error (unknown): #{e}"
            puts e.backtrace.map { |x| "[VAL]!\t #{x}" }
            error_callback.call(['An Unknown Error Occured'])
            false
        end
    end

    def self.raise_error msg
        raise MiscError.new(msg)
    end
end