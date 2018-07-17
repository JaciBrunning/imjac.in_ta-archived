module Webcore
    module Utils
        FILESIZE_PREFIXES = %w{k M G T P E Z Y}
        def self.filesize bytes
            if bytes < 1000
            bytes.to_s + "B"
            else
                pos = (Math.log(bytes) / Math.log(1000)).floor
                pos = FILESIZE_PREFIXES.size - 1 if pos > FILESIZE_PREFIXES.size-1

                unit = FILESIZE_PREFIXES[pos-1] + "B"
                (bytes.to_f / 1000**pos).round(2).to_s + unit
            end
        end

        def self.render_time_delay seconds
            mm, ss = seconds.divmod(60)
            hh, mm = mm.divmod(60)
            strbuilder = []
            strbuilder << "#{hh.round(0)}h" if hh > 0
            strbuilder << "#{mm.round(0)}m" if mm > 0
            strbuilder << "#{ss.round(0)}s"

            strbuilder.join(" ")
        end

        def self.strippath path
            path.sub('\\', '/').split('/').reject { |x| x == '..' }.join('/')
        end
    end
end