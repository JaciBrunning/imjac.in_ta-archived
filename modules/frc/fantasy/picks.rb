require 'json'
require 'csv'
require 'open-uri'
require 'jobs'

class FFPicks
    FF_FETCH = "https://docs.google.com/spreadsheets/d/e/2PACX-1vQjcb0R67aRvvSIOdrZNofq1pPZ4JbZ9WtNII4N2skgZhIw4m2hjQcO28kHEQN3YfI-ZchEUUTHMSoe/pub?gid=1028864003&single=true&output=csv"
    FF_REGEX = /\[(\d+)\]\s([^₪]+)\s₪(\d+)/

    def initialize
        @ff_entries = "[]"
        @job = Job.new("Update Fantasy FIRST Picks", 300, true) {
            content = open(FF_FETCH).read.force_encoding("utf-8")
            csv = CSV.parse(content)
            rows = csv[1..-1]
            results = rows.map do |row|
                unless row[1].nil? || row[1].empty?
                    picks = row[1].scan(FF_REGEX).map do |pick|
                        { team: pick[0].to_i, name: pick[1], cost: pick[2].to_i }
                    end
                    spent = picks.map{ |i| i[:cost] }.inject(:+)
                    { team: row[0], picks: picks, spent: spent }
                else
                    nil
                end
            end.reject(&:nil?)
            puts "FF Entries: #{results.size}"
            @ff_entries = JSON.generate(results)
        }
        @job.run
        Jobs.submit(@job)
    end

    def get
        @ff_entries
    end
end