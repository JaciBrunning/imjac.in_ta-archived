require 'sinatra/base'
require 'utils'
require 'libs'
require_relative 'picks.rb'
require_relative 'event.rb'

FANTASY_WWW_FOLDER = File.join(web_root(), '_public/dev')
FileUtils.mkdir_p FANTASY_WWW_FOLDER

class FantasyModule < Sinatra::Base
    register Extensions::Resources

    picks = FFPicks.new("pickem", "https://docs.google.com/spreadsheets/d/e/2PACX-1vQjcb0R67aRvvSIOdrZNofq1pPZ4JbZ9WtNII4N2skgZhIw4m2hjQcO28kHEQN3YfI-ZchEUUTHMSoe/pub?gid=1028864003&single=true&output=csv")
    hosts = FFPicks.new("host", "https://docs.google.com/spreadsheets/d/e/2PACX-1vQjcb0R67aRvvSIOdrZNofq1pPZ4JbZ9WtNII4N2skgZhIw4m2hjQcO28kHEQN3YfI-ZchEUUTHMSoe/pub?gid=2122248721&single=true&output=csv")
    liveevent = FRCLiveEvent.new("2018dar")

    get "/?" do
        @title = "Fantasy FIRST"
        @js = [
            :react,
            :'fanfirst/fanfirst',
            :'fanfirst/title',
            :'fanfirst/selector',
            :'fanfirst/tabs/pickview',
            :'fanfirst/tabs/pointsview',
            :'fanfirst/tabs/leaderboard'
        ]
        @css = [:fantasyfirst]
        erb :index
    end

    get "/ta/?" do
        redirect "/"
    end

    get "/setevent/:event" do |evkey|
        liveevent.stop
        liveevent = FRCLiveEvent.new(evkey)
    end

    get "/picks.json" do
        content_type 'application/json'
        picks.get
    end

    get "/hosts.json" do
        content_type 'application/json'
        hosts.get
    end

    get "/event.json" do
        content_type 'application/json'
        liveevent.event_info_json
    end

    get "/points.json" do
        content_type 'application/json'
        liveevent.points_json
    end
end

define_webcore_module :'fantasy.frc', FantasyModule
define_virtual_server /fantasy.frc.*/, :'fantasy.frc'

Builders.register :fantasyfirst_css, CSSBuilder.new(File.join(File.dirname(__FILE__), 'css/fantasy.scss'), 'fantasyfirst.css')
Libs.register_css :fantasyfirst, "/res/css/fantasyfirst.css"

Builders.register :fantasyfirst_jsx, JSBuilder.new(
    File.join(File.dirname(__FILE__), 'jsx'),
    out: 'react/fanfirst',
    lib: Proc.new { |x| "fanfirst/#{x}".to_sym }
)
