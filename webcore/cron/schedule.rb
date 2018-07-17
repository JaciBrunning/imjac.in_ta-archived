module Webcore
    class CronSchedule
        attr_reader :minute
        attr_reader :hour
        attr_reader :dayofmonth
        attr_reader :month
        attr_reader :dayofweek

        def initialize cronstring
            load_cronstring cronstring
        end

        def load_cronstring str
            @minute, @hour, @dayofmonth, @month, @dayofweek = str.split(/\s+/).map do |x| 
                x == "*" ? nil : x.split(",").map(&:to_i)
            end
        end

        def check? member, actual
            member == nil || member.include?(actual)
        end

        def trigger? time
            dow = @dayofweek
            dow = 7 if dow == 0
            
            check?(dow, time.cwday) &&
                check?(@month, time.month) &&
                check?(@dayofmonth, time.mday) &&
                check?(@hour, time.hour) &&
                check?(@minute, time.minute)
        end

        def to_s
            "Schedule[#{minute} #{hour} #{dayofmonth} #{month} #{dayofweek}]"
        end
    end
end