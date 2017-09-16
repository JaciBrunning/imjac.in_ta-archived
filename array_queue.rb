require 'thread'

class ArrayQueue < Array
    def initialize
        super()
        @mutex = Mutex.new
        @cv = ConditionVariable.new
    end

    def pushQ item
        @mutex.synchronize {
            self.push(item)
            @cv.signal
        }
    end

    def popQ
        item = nil
        @mutex.synchronize {
            @cv.wait @mutex unless size > 0
            item = self.pop
        }
        item
    end
end