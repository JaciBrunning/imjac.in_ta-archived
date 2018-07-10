require 'sinatra/base'
require 'utils'
require 'libs'
require_relative 'picks.rb'
require_relative 'event.rb'

FANTASY_WWW_FOLDER = File.join(web_root(), '_public/dev')
FileUtils.mkdir_p FANTASY_WWW_FOLDER

class FantasyModule < Sinatra::Base
    register Extensions::Resources

    picks = FFPicks.new
    liveevent = FRCLiveEvent.new("2018iri")

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

    get "/entries.json" do
        content_type 'application/json'
        picks.get
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
