require 'webcore/cdn/extension'
require 'webcore/db/authextension'

require_relative 'elsiecalendar/elsiecalendar'

class ProjectModule < WebcoreApp()
    register CDNExtension
    register AuthExtension
    register ElsieCalendar

    set :views, "#{File.dirname(__FILE__)}/views"

    before do 
        https!
    end

    get "/?" do
        redirect "/ta"
    end

    get "/ta" do
        @title = "Index"
        erb :index
    end
end