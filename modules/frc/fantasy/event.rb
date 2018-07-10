require 'json'
require 'csv'
require 'open-uri'
require 'jobs'

# TODO: I should split TBA requests into their own utility class
class FRCLiveEvent
    attr_accessor :event_code
    attr_accessor :event_info
    attr_accessor :points

    attr_accessor :points_json
    attr_accessor :event_info_json

    # The TBA devs are fine with me sharing this key. This is the default, you can override it with the
    # TBA_API_KEY environment variable.
    # This particular key may be killed at any time (or rate limited)
    DEFAULT_API_KEY = "19iOXH0VVxCvYQTlmIRpXyx2xoUQuZoWEPECGitvJcFxEY6itgqDP7A4awVL2CJn"

    POINTS = {
        qwin: 2,
        ewin: 5,
        qtie: 1
    }

    def initialize event_code
        @event_code = event_code
        @apikey = ENV['TBA_API_KEY'] || DEFAULT_API_KEY
        update_event

        @job = Job.new("Update Fantasy FIRST Data", 30, true) {
            update
        }
        @job.run
        Jobs.submit(@job)
    end

    def request path
        JSON.parse open("https://www.thebluealliance.com/api/v3/#{path}?X-TBA-Auth-Key=#{@apikey}").read
    end

    def update_event
        req = request "event/#{event_code}/simple"
        @event_info = {
            name: req["name"],
            year: req["year"],
            key: req["key"],
            pconfig: @points_config
        }
        @event_info_json = JSON.generate(@event_info)
    end

    def update
        teams = request "event/#{event_code}/teams/statuses"
        matches = request "event/#{event_code}/matches/simple"

        @points = {  }
        teams.each do |team, status|
            p = {
                total: 0,
                qwins: 0,
                ewins: 0,
                ties: 0,
                draft: 0
            }

            unless status["alliance"].nil?
                alliance = status["alliance"]
                alliancenum = alliance["number"].to_i
                alliancepick = alliance["pick"].to_i 

                p[:draft] = [ 17 - alliancenum, 17 - alliancenum, alliancenum, 0, 0 ][alliancepick]
                p[:total] += p[:draft]
            end

            @points[team[3..-1].to_i] = p
        end

        matches.each do |match|
            red = match["alliances"]["blue"]["team_keys"].map { |t| t[3..-1].to_i }
            blue = match["alliances"]["blue"]["team_keys"].map { |t| t[3..-1].to_i }
            elim = match["comp_level"] != "qm"
            winner = match["winning_alliance"]
            
            winkey = elim ? :ewins : :qwins
            winval = POINTS[elim ? :ewin : :qwin]
            if winner.empty? && !elim
                (red + blue).each { |t| 
                    points[t][:total] += POINTS[:qtie]
                    points[t][:ties] += 1
                }
            elsif winner == "blue"
                blue.each { |t| 
                    points[t][:total] += winval
                    points[t][winkey] += 1
                }
            elsif winner = "red"
                red.each { |t|
                    points[t][:total] += winval
                    points[t][winkey] += 1
                }
            end
        end

        @points_json = JSON.generate(@points)
    end
end