require 'webcore/cdn/resource'
require_relative 'req'
require_relative 'timetable'

module ElsieCalendar
    def self.registered app
        erbfile = lambda { |f| File.read("#{File.dirname(__FILE__)}/views/#{f.to_s}.erb") }

        app.get "/ta/elsie/?" do
            https!
            @title = "Elsie Calendar"
            erb erbfile.call("index")
        end

        app.post "/ta/elsie/?" do
            https!
            begin
                user = params["curtin_login"]
                pass = params["curtin_password"]
                startdate = DateTime.parse(params["start_date"])
                enddate = DateTime.parse(params["end_date"])

                redirect "/ta/elsie?error=No username or password" if user.nil? || pass.nil?
                redirect "/ta/elsie?error=Invalid dates" if startdate > enddate

                r = ElsieRequests.new user, pass
                timelines = r.get("timelines/study/entries?startDateTime=#{startdate.to_date.to_s}&endDateTime=#{enddate.to_date.to_s}&modifiedAfter=1970-01-01")
                redirect "/ta/elsie?error=Wrong Username or Password" unless timelines["collection"].is_a? Array
                timetable = Timetable.new(timelines["collection"].select { |x| !x["isDeleted"] })
                content_type 'text/calendar'
                response['Content-Disposition'] = "attachment; filename=Curtin_#{user}_#{startdate.strftime('%Y%m%d')}_#{enddate.strftime('%Y%m%d')}.ics"
                timetable.calendar.to_ical
            rescue => e
                redirect "/ta/elsie?error=Unknown Error"
            end
        end
    end
end