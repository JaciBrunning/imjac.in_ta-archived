require 'json'
require 'csv'
require 'open-uri'
require 'jobs'

class FFPicks
    FF_REGEX = /\[(\d+)\]\s([^₪]+)\s₪(\d+)/

    def initialize tag, url
        @ff_entries = "[]"
        # Every half an hour
        @job = Job.new("Update Fantasy FIRST Picks #{tag}", 1800, true) {
            content = open(url).read.force_encoding("utf-8")
            csv = CSV.parse(content)
            rows = csv[1..-1]
            results = rows.map do |row|
                unless row[1].nil? || row[1].empty?
                    picks = row[1].scan(FF_REGEX).map do |pick|
                        { team: pick[0].to_i, name: pick[1], cost: pick[2].to_i }
                    end
                    spent = picks.map{ |i| i[:cost] }.inject(:+)
                    { team: row[0], picks: picks, spent: spent, tag: tag }
                else
                    nil
                end
            end.reject(&:nil?)
            puts "FF Entries: #{results.size}"
            @ff_entries = JSON.generate(results)
        }
        @job.immediate = true
        Jobs.submit(@job)
    end

    def get
        @ff_entries
    end
end